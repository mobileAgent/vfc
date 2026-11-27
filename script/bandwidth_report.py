#!/usr/bin/env python3
"""Bandwidth report for the Apache vhost access logs on the shared host.

Reads /var/log/apache2/other_vhosts_access.log and its rotations (.1, .2.gz,
...) in the vhost_combined format and prints:

  1. GB per day per vhost
  2. GB per day by kind of request for one vhost (audio download, audio
     play, assets, pages ...)
  3. Audio requests per day by response: served / refused / redirected
  4. Who is getting audio: top /16 networks and IPs, and how spread out the
     downloaders are (rotating-proxy scrapers show up as huge numbers of IPs
     with only 1-2 downloads each)
  5. Served audio by Referer (our own sites / none / elsewhere) and client
  6. Mobile app (Dart/ user agent) traffic, to spot anyone faking it
  7. AUDIO_GATE reasons per day from the Rails production.log and its
     rotations (production.log-20261105, production.log-20261104.gz, ...)
  8. Through Cloudflare or straight to the server, per day for all vhosts,
     and which Host the refused audio requests named. Needs the connecting
     address (%{c}a) after the visitor address in the LogFormat, and for the
     Host table a quoted %{Host}i at the end of the line; older lines
     without them are counted as "unknown".

Both logs rotate daily, so with --days/--since/--until only the files that
can hold those days are read: each file's first timestamp says where it
starts, and the walk from newest to oldest stops at the first file that
starts before the range (that one still holds the range's first minutes,
since rotation happens a little after midnight).

Usage (needs read access to the logs, so usually with sudo):
  sudo python3 bandwidth_report.py --days 3        # today and the 2 days before (UTC)
  sudo python3 bandwidth_report.py --since 2026-10-23 --until 2026-10-24
  sudo python3 bandwidth_report.py --days 2 --hourly 2026-11-05   # that day by hour
  sudo python3 bandwidth_report.py                 # every log file present
  sudo python3 bandwidth_report.py --rails-log none   # skip the Rails log

Only uses the Python 3 standard library.
"""

import argparse
import glob
import gzip
import ipaddress
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone

DEFAULT_LOG_GLOB = '/var/log/apache2/other_vhosts_access.log*'
DEFAULT_RAILS_LOG = '/var/apps/vfc/current/log/production.log'
DEFAULT_CF_IPS = '/etc/apache2/cloudflare-ips.txt'
OUR_SITES = ['voicesforchrist.net', 'voicesforchrist.org', 'voixpourchrist.org',
             'vocesparacristo.org', 'vfc.io']
GB = 1e9

# voicesforchrist.net:443 1.2.3.4 - - [23/Oct/2026:00:44:55 +0000] "GET /x HTTP/1.1" 200 5552 "ref" "ua"
# Since the Cloudflare move the connecting address (%{c}a) may follow the
# visitor's, and a quoted Host may end the line:
# voicesforchrist.net:443 1.2.3.4 172.70.1.2 - - [...] "GET /x HTTP/1.1" 200 5552 "ref" "ua" "vfc.io"
LINE = re.compile(
    r'^(?P<vhost>\S+) (?P<ip>\S+) (?:(?P<peer>[0-9A-Fa-f.:]+) )?\S+ \S+ '
    r'\[(?P<day>[^:\]]+):(?P<hour>\d\d)[^\]]*\] '
    r'"(?P<request>[^"]*)" (?P<status>\d{3}) (?P<bytes>\d+|-)'
    r'(?: "(?P<ref>[^"]*)" "(?P<ua>[^"]*)")?(?: "(?P<host>[^"]*)")?')
AUDIO = re.compile(r'^/audio_messages/\d+(?:$|\?)')
# Apache: [23/Oct/2026:00:44:55 +0000]   Rails: W, [2026-10-24T15:35:27.050166 #1896250]
ACCESS_DATE = re.compile(r'\[(\d\d/\w{3}/\d{4}):')
RAILS_DATE = re.compile(r'\[(\d{4}-\d\d-\d\d)T')
GATE = re.compile(r'AUDIO_GATE (deny reason=\S+|app_signature \S+)')


def parse_args():
    p = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    p.add_argument('--logs', default=DEFAULT_LOG_GLOB,
                   help='glob for the access logs (default: %(default)s)')
    p.add_argument('--days', type=int, help='only the last N days (by log date)')
    p.add_argument('--since', help='first day to include, YYYY-MM-DD')
    p.add_argument('--until', help='last day to include, YYYY-MM-DD')
    p.add_argument('--vhost', default='voicesforchrist.net',
                   help='vhost for the per-request-kind and audio sections (default: %(default)s)')
    p.add_argument('--top', type=int, default=15, help='rows in the top-N tables (default: %(default)s)')
    p.add_argument('--hourly', metavar='YYYY-MM-DD',
                   help='also show that day hour by hour for the chosen vhost')
    p.add_argument('--rails-log', default=DEFAULT_RAILS_LOG,
                   help='current Rails log; its dated rotations next to it are read too, '
                        '"none" to skip (default: %(default)s)')
    p.add_argument('--cf-ips', default=DEFAULT_CF_IPS,
                   help='Cloudflare address ranges, one per line, for telling proxied '
                        'requests from direct ones (default: %(default)s)')
    return p.parse_args()


def open_log(path):
    if path.endswith('.gz'):
        return gzip.open(path, 'rt', errors='replace')
    return open(path, 'r', errors='replace')


def newest_first(paths):
    # The live file, then .1, .2.gz ... (Apache) or -20261105, -20261104.gz ... (Rails).
    def age(path):
        m = re.search(r'\.log\.(\d+)(?:\.gz)?$', path)
        if m:
            return (1, int(m.group(1)))
        m = re.search(r'\.log-(\d{8})(?:\.gz)?$', path)
        if m:
            return (1, -int(m.group(1)))
        return (0, 0)
    return sorted(paths, key=age)


def parse_day(text):
    return datetime.strptime(text, '%d/%b/%Y').date()


def parse_rails_day(text):
    return datetime.strptime(text, '%Y-%m-%d').date()


def first_day_in(path, pattern, parse):
    """Date of the first timestamped line, or None for an empty file."""
    with open_log(path) as f:
        for i, line in enumerate(f):
            m = pattern.search(line)
            if m:
                try:
                    return parse(m.group(1))
                except ValueError:
                    pass
            if i > 1000:
                break
    return None


def files_for_range(paths, pattern, parse, since, until):
    """Oldest-first list of the rotated files that can hold since..until."""
    paths = newest_first(paths)
    if not since and not until:
        return list(reversed(paths))
    chosen = []
    for path in paths:
        start = first_day_in(path, pattern, parse)
        if start and until and start > until:
            continue
        chosen.append(path)
        # Everything older ends before this file starts.
        if start and since and start < since:
            break
    return list(reversed(chosen))


def load_networks(path):
    try:
        with open(path) as f:
            return [ipaddress.ip_network(l.strip(), strict=False) for l in f if l.strip()]
    except (OSError, ValueError) as e:
        sys.stderr.write('no Cloudflare ranges from %s (%s); route section skipped\n' % (path, e))
        return []


def route_of(peer, cf_nets, cache):
    """'cloudflare', 'direct', 'local' or 'unknown' (an older line without %{c}a)."""
    if not peer:
        return 'unknown'
    route = cache.get(peer)
    if route is None:
        try:
            addr = ipaddress.ip_address(peer)
        except ValueError:
            route = 'unknown'
        else:
            if addr.is_loopback:
                route = 'local'
            elif any(addr in n for n in cf_nets if n.version == addr.version):
                route = 'cloudflare'
            else:
                route = 'direct'
        cache[peer] = route
    return route


def kind_of(path):
    if AUDIO.match(path):
        return 'audio download' if 'dl=true' in path else 'audio play'
    base = path.split('?', 1)[0]
    if base == '/':
        return '/'
    first = '/' + base.split('/')[1]
    return first


def network16(ip):
    try:
        addr = ipaddress.ip_address(ip)
    except ValueError:
        return ip
    prefix = 16 if addr.version == 4 else 32
    return str(ipaddress.ip_network('%s/%d' % (ip, prefix), strict=False))


def referer_class(ref):
    if not ref or ref == '-':
        return 'none'
    host = re.sub(r'^https?://', '', ref).split('/', 1)[0].split(':')[0].lower()
    for site in OUR_SITES:
        if host == site or host.endswith('.' + site):
            return 'our site (%s)' % site
    return 'elsewhere (%s)' % host


def client_class(ua):
    ua = ua or ''
    if ua.startswith('Dart/'):
        return 'mobile app (Dart)'
    if re.search(r'bot|crawl|spider|slurp', ua, re.I):
        return 'declared bot'
    if 'iPhone' in ua or 'iPad' in ua:
        return 'iOS'
    if 'Android' in ua:
        return 'Android'
    if 'Windows' in ua:
        return 'Windows'
    if 'Macintosh' in ua:
        return 'Mac'
    if 'Linux' in ua:
        return 'Linux desktop'
    return 'other'


def gb(n):
    return '%.1f' % (n / GB) if n >= 0.05 * GB or n == 0 else '%.2f' % (n / GB)


def table(title, header, rows):
    print('\n== %s ==' % title)
    if not rows:
        print('  (nothing)')
        return
    rows = [[str(c) for c in r] for r in rows]
    widths = [max(len(header[i]), *(len(r[i]) for r in rows)) for i in range(len(header))]
    fmt = '  ' + '  '.join('%%%ds' % w if i else '%%-%ds' % w for i, w in enumerate(widths))
    print(fmt % tuple(header))
    print('  ' + '  '.join('-' * w for w in widths))
    for r in rows:
        print(fmt % tuple(r))


def main():
    args = parse_args()
    since = datetime.strptime(args.since, '%Y-%m-%d').date() if args.since else None
    if args.days:
        since = datetime.now(timezone.utc).date() - timedelta(days=args.days - 1)
    until = datetime.strptime(args.until, '%Y-%m-%d').date() if args.until else None
    hourly_day = datetime.strptime(args.hourly, '%Y-%m-%d').date() if args.hourly else None

    all_files = glob.glob(args.logs)
    if not all_files:
        sys.exit('No log files match %s' % args.logs)
    files = files_for_range(all_files, ACCESS_DATE, parse_day, since, until)

    day_cache = {}
    vhost_day = defaultdict(int)          # (day, vhost) -> bytes
    kind_day = defaultdict(int)           # (day, kind) -> bytes for args.vhost
    audio_status = defaultdict(lambda: defaultdict(int))   # day -> outcome -> count
    audio_day_bytes = defaultdict(int)
    hourly = defaultdict(lambda: [0, 0, 0])  # hour -> [all bytes, audio bytes, audio refused]
    net_bytes = defaultdict(int)
    net_ips = defaultdict(set)
    ip_bytes = defaultdict(int)
    ip_count = defaultdict(int)
    ip_ua = {}
    ref_bytes = defaultdict(int)
    client_bytes = defaultdict(int)
    client_count = defaultdict(int)
    dart_day = defaultdict(lambda: [0, 0, set()])  # day -> [requests, bytes, ips]
    dart_ip = defaultdict(int)
    cf_nets = load_networks(args.cf_ips)
    route_cache = {}
    route_day = defaultdict(lambda: [0, 0, 0, 0])  # (day, route) -> [requests, bytes, 403s, 403 bytes]
    direct_ip = defaultdict(int)          # direct connecting address -> requests
    refused_host = defaultdict(int)       # Host of refused audio for args.vhost -> requests
    bad_lines = 0
    first_day = last_day = None

    for path in files:
        sys.stderr.write('reading %s\n' % path)
        with open_log(path) as f:
            for line in f:
                m = LINE.match(line)
                if not m:
                    bad_lines += 1
                    continue
                raw_day = m.group('day')
                day = day_cache.get(raw_day)
                if day is None:
                    try:
                        day = day_cache[raw_day] = parse_day(raw_day)
                    except ValueError:
                        bad_lines += 1
                        continue
                if since and day < since or until and day > until:
                    continue
                first_day = day if first_day is None or day < first_day else first_day
                last_day = day if last_day is None or day > last_day else last_day

                vhost = m.group('vhost').rsplit(':', 1)[0]
                size = 0 if m.group('bytes') == '-' else int(m.group('bytes'))
                vhost_day[(day, vhost)] += size
                status = m.group('status')
                if cf_nets:
                    route = route_of(m.group('peer'), cf_nets, route_cache)
                    r = route_day[(day, route)]
                    r[0] += 1
                    r[1] += size
                    if status == '403':
                        r[2] += 1
                        r[3] += size
                    if route == 'direct':
                        direct_ip[m.group('peer')] += 1
                if vhost != args.vhost:
                    continue

                parts = m.group('request').split(' ')
                req_path = parts[1] if len(parts) > 1 else ''
                kind = kind_of(req_path)
                kind_day[(day, kind)] += size
                ip = m.group('ip')
                ua = m.group('ua') or ''
                is_audio = kind.startswith('audio')
                if day == hourly_day:
                    h = hourly[m.group('hour')]
                    h[0] += size
                    if is_audio:
                        h[1] += size if status in ('200', '206') else 0
                        h[2] += 1 if status not in ('200', '206') else 0
                if not is_audio:
                    continue

                if status in ('200', '206'):
                    outcome = 'served'
                elif status == '403':
                    outcome = 'refused 403'
                elif status in ('301', '302'):
                    outcome = 'redirect %s' % status
                elif status == '429':
                    outcome = 'app over budget 429'
                else:
                    outcome = 'other %s' % status
                audio_status[day][outcome] += 1
                if outcome != 'served' and m.group('host') is not None:
                    refused_host[m.group('host').split(':')[0].lower() or '-'] += 1
                if ua.startswith('Dart/'):
                    d = dart_day[day]
                    d[0] += 1
                    d[1] += size
                    d[2].add(ip)
                    if outcome == 'served':
                        dart_ip[ip] += 1
                if outcome != 'served':
                    continue

                audio_day_bytes[day] += size
                net = network16(ip)
                net_bytes[net] += size
                net_ips[net].add(ip)
                ip_bytes[ip] += size
                ip_count[ip] += 1
                ip_ua[ip] = ua
                ref_bytes[referer_class(m.group('ref'))] += size
                client = client_class(ua)
                client_bytes[client] += size
                client_count[client] += 1

    if first_day is None:
        sys.exit('No log lines in the selected date range.')

    days = sorted({d for d, _ in vhost_day})
    print('Bandwidth report: %s to %s (%d of %d access log files read, %d unparsed lines)'
          % (days[0], days[-1], len(files), len(all_files), bad_lines))

    # 1. vhost x day
    totals = defaultdict(int)
    for (d, v), n in vhost_day.items():
        if d in days:
            totals[v] += n
    vhosts = [v for v, n in sorted(totals.items(), key=lambda x: -x[1]) if n >= 0.01 * GB][:8]
    rows = []
    for d in days:
        row = [d.strftime('%a %Y-%m-%d')]
        row += [gb(vhost_day[(d, v)]) for v in vhosts]
        row.append(gb(sum(n for (dd, _), n in vhost_day.items() if dd == d)))
        rows.append(row)
    rows.append(['TOTAL'] + [gb(totals[v]) for v in vhosts] + [gb(sum(totals.values()))])
    table('GB per day per vhost (vhosts over 0.01 GB)', ['day'] + vhosts + ['all'], rows)

    # 2. kinds of request for the chosen vhost
    kind_totals = defaultdict(int)
    for (d, k), n in kind_day.items():
        if d in days:
            kind_totals[k] += n
    kinds = [k for k, _ in sorted(kind_totals.items(), key=lambda x: -x[1])][:7]
    rows = [[d.strftime('%a %Y-%m-%d')] + [gb(kind_day[(d, k)]) for k in kinds] for d in days]
    rows.append(['TOTAL'] + [gb(kind_totals[k]) for k in kinds])
    table('GB per day by request kind, %s' % args.vhost, ['day'] + kinds, rows)

    # 3. audio outcomes
    outcomes = sorted({o for d in days for o in audio_status[d]})
    rows = [[d.strftime('%a %Y-%m-%d'), gb(audio_day_bytes[d])] +
            [audio_status[d][o] for o in outcomes] for d in days]
    table('Audio requests per day by response, %s' % args.vhost,
          ['day', 'GB served'] + outcomes, rows)

    if hourly_day:
        rows = [[h, gb(v[0]), gb(v[1]), v[2]] for h, v in sorted(hourly.items())]
        table('Hour by hour on %s (UTC), %s' % (hourly_day, args.vhost),
              ['hour', 'GB all', 'GB audio served', 'audio refused'], rows)

    # 4. who gets audio
    note = '(%s to %s)' % (days[0], days[-1])
    rows = [[net, gb(n), len(net_ips[net])]
            for net, n in sorted(net_bytes.items(), key=lambda x: -x[1])[:args.top]]
    table('Top networks for served audio %s' % note, ['network', 'GB', 'IPs'], rows)

    rows = [[ip, gb(n), ip_count[ip], client_class(ip_ua.get(ip)), (ip_ua.get(ip) or '')[:60]]
            for ip, n in sorted(ip_bytes.items(), key=lambda x: -x[1])[:args.top]]
    table('Top IPs for served audio', ['ip', 'GB', 'files', 'client', 'user agent'], rows)

    buckets = [('1-2', 1, 2), ('3-10', 3, 10), ('11-100', 11, 100), ('>100', 101, 10 ** 12)]
    rows = []
    for name, lo, hi in buckets:
        ips = [ip for ip, c in ip_count.items() if lo <= c <= hi]
        rows.append([name, len(ips), gb(sum(ip_bytes[ip] for ip in ips))])
    table('How spread out audio downloaders are (many IPs at 1-2 files = rotating proxies)',
          ['files per IP', 'IPs', 'GB'], rows)

    # 5. referer and client
    rows = [[r, gb(n)] for r, n in sorted(ref_bytes.items(), key=lambda x: -x[1])[:args.top]]
    table('Served audio by Referer', ['referer', 'GB'], rows)
    rows = [[c, gb(n), client_count[c]] for c, n in sorted(client_bytes.items(), key=lambda x: -x[1])]
    table('Served audio by client', ['client', 'GB', 'requests'], rows)

    # 6. mobile app
    rows = [[d.strftime('%a %Y-%m-%d'), dart_day[d][0], gb(dart_day[d][1]), len(dart_day[d][2])]
            for d in days if d in dart_day]
    table('Mobile app (Dart/ user agent) audio requests', ['day', 'requests', 'GB', 'IPs'], rows)
    rows = [[ip, c] for ip, c in sorted(dart_ip.items(), key=lambda x: -x[1])[:5]]
    table('Busiest app IPs (normal is a few dozen files over days; hundreds suggests a fake)',
          ['ip', 'files served'], rows)

    # 8. through Cloudflare or straight to the server
    if cf_nets:
        routes = [r for r in ('cloudflare', 'direct', 'local', 'unknown')
                  if any((d, r) in route_day for d in days)]
        rows = []
        for d in days:
            for r in routes:
                if (d, r) in route_day:
                    v = route_day[(d, r)]
                    rows.append([d.strftime('%a %Y-%m-%d'), r, v[0], gb(v[1]), v[2], gb(v[3])])
        table('Through Cloudflare or direct to the server, all vhosts '
              '("unknown" = lines logged before %{c}a was added)',
              ['day', 'route', 'requests', 'GB', '403s', '403 GB'], rows)
        rows = [[ip, n] for ip, n in sorted(direct_ip.items(), key=lambda x: -x[1])[:args.top]]
        table('Busiest direct (not Cloudflare) connecting addresses', ['address', 'requests'], rows)
        if refused_host:
            rows = [[h, n] for h, n in sorted(refused_host.items(), key=lambda x: -x[1])[:args.top]]
            table('Refused audio by requested Host, %s' % args.vhost, ['host', 'requests'], rows)

    # 7. Rails AUDIO_GATE lines over the same days
    if args.rails_log != 'none':
        rails_report(args.rails_log, since, until, days)


def rails_report(base, since, until, access_days):
    all_files = glob.glob(base) + glob.glob(base + '-*')
    if not all_files:
        print('\n(no Rails log at %s; use --rails-log PATH or --rails-log none)' % base)
        return
    # Rails stamps lines in the server's local time; on this host that's UTC,
    # the same as the access log.
    per_day = defaultdict(lambda: defaultdict(int))   # day -> what -> count
    try:
        files = files_for_range(all_files, RAILS_DATE, parse_rails_day, since, until)
        for path in files:
            sys.stderr.write('reading %s\n' % path)
            with open_log(path) as f:
                for line in f:
                    if 'AUDIO_GATE' not in line:
                        continue
                    m = GATE.search(line)
                    d = RAILS_DATE.search(line)
                    if not m or not d:
                        continue
                    day = parse_rails_day(d.group(1))
                    if since and day < since or until and day > until:
                        continue
                    per_day[day][m.group(1)] += 1
    except OSError as e:
        print('\n(could not read the Rails log: %s)' % e)
        return

    totals = defaultdict(int)
    for counts in per_day.values():
        for what, n in counts.items():
            totals[what] += n
    whats = [w for w, _ in sorted(totals.items(), key=lambda x: -x[1])][:8]
    days = sorted(set(access_days) | set(per_day))
    rows = [[d.strftime('%a %Y-%m-%d')] + [per_day[d][w] for w in whats] for d in days]
    rows.append(['TOTAL'] + [totals[w] for w in whats])
    table('AUDIO_GATE per day (%d of %d Rails log files read)' % (len(files), len(all_files)),
          ['day'] + [w.replace('deny reason=', '') for w in whats], rows if whats else [])


if __name__ == '__main__':
    main()
