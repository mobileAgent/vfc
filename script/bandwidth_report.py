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
  7. Optionally, AUDIO_GATE reasons from the Rails production.log

Usage (needs read access to the logs, so usually with sudo):
  sudo python3 bandwidth_report.py                 # every log file present
  sudo python3 bandwidth_report.py --days 3        # today and the 2 days before (UTC)
  sudo python3 bandwidth_report.py --since 2026-10-23 --until 2026-10-24
  sudo python3 bandwidth_report.py --hourly 2026-10-23   # one day by hour
  sudo python3 bandwidth_report.py --rails-log /var/apps/vfc/current/log/production.log

Only uses the Python 3 standard library.
"""

import argparse
import glob
import gzip
import ipaddress
import os
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta

DEFAULT_LOG_GLOB = '/var/log/apache2/other_vhosts_access.log*'
OUR_SITES = ['voicesforchrist.net', 'voicesforchrist.org', 'voixpourchrist.org',
             'vocesparacristo.org', 'vfc.io']
GB = 1e9

# voicesforchrist.net:443 1.2.3.4 - - [23/Oct/2026:00:44:55 +0000] "GET /x HTTP/1.1" 200 5552 "ref" "ua"
LINE = re.compile(
    r'^(?P<vhost>\S+) (?P<ip>\S+) \S+ \S+ \[(?P<day>[^:\]]+):(?P<hour>\d\d)[^\]]*\] '
    r'"(?P<request>[^"]*)" (?P<status>\d{3}) (?P<bytes>\d+|-)'
    r'(?: "(?P<ref>[^"]*)" "(?P<ua>[^"]*)")?')
AUDIO = re.compile(r'^/audio_messages/\d+(?:$|\?)')


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
    p.add_argument('--rails-log', help='production.log to summarize AUDIO_GATE lines from')
    return p.parse_args()


def open_log(path):
    if path.endswith('.gz'):
        return gzip.open(path, 'rt', errors='replace')
    return open(path, 'r', errors='replace')


def log_files(pattern):
    # Oldest first: .10.gz ... .2.gz, .1, then the live file.
    def age(path):
        m = re.search(r'\.log\.(\d+)', path)
        return -int(m.group(1)) if m else 0
    return sorted(glob.glob(pattern), key=age)


def parse_day(text):
    return datetime.strptime(text, '%d/%b/%Y').date()


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
    files = log_files(args.logs)
    if not files:
        sys.exit('No log files match %s' % args.logs)

    since = datetime.strptime(args.since, '%Y-%m-%d').date() if args.since else None
    if args.days:
        since = datetime.utcnow().date() - timedelta(days=args.days - 1)
    until = datetime.strptime(args.until, '%Y-%m-%d').date() if args.until else None
    hourly_day = datetime.strptime(args.hourly, '%Y-%m-%d').date() if args.hourly else None

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
                if vhost != args.vhost:
                    continue

                parts = m.group('request').split(' ')
                req_path = parts[1] if len(parts) > 1 else ''
                kind = kind_of(req_path)
                kind_day[(day, kind)] += size
                status = m.group('status')
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
    print('Bandwidth report: %s to %s (%d log files, %d unparsed lines)'
          % (days[0], days[-1], len(files), bad_lines))

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

    # 7. Rails AUDIO_GATE lines
    if args.rails_log:
        reasons = defaultdict(int)
        with open_log(args.rails_log) as f:
            for line in f:
                if 'AUDIO_GATE' not in line:
                    continue
                m = re.search(r'AUDIO_GATE (deny reason=\S+|app_signature \S+)', line)
                if m:
                    reasons[m.group(1)] += 1
        rows = [[r, n] for r, n in sorted(reasons.items(), key=lambda x: -x[1])]
        table('AUDIO_GATE in %s (whole file)' % os.path.basename(args.rails_log),
              ['what', 'count'], rows)


if __name__ == '__main__':
    main()
