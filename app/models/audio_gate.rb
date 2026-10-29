require 'ipaddr'
require 'openssl'

# Decides who may fetch an audio file.
#
# Scrapers were walking /audio_messages/:id from rotating residential
# proxies. Pages now hand out audio links carrying a token signed over the
# message id, an expiry and the viewer's /24 network, so a bare id (or a
# token harvested from a different IP) no longer gets the file.
#
# The mobile app builds its download URL from the message id alone and
# installed copies can't be updated quickly, so requests with its Dart user
# agent are let through without a token, within daily budgets that cap the
# damage if someone fakes that user agent. Normal app use is under 100
# downloads a day.
#
# Newer app builds also send X-VFC-App-Signature, an HMAC over the message
# id and a timestamp made with a key baked into the app at build time. The
# matching keys live in Rails credentials as `audio_app_keys` (a list, so a
# new key can ship before the old one is retired). Signed requests skip the
# user-agent budgets and get their own, larger one, so a key pulled out of
# the app binary still can't run up the bill.
module AudioGate
  TOKEN_TTL = 24.hours
  APP_USER_AGENT = /\ADart\//
  APP_DAILY_LIMIT = (ENV['VFC_APP_DAILY_LIMIT'] || 500).to_i
  APP_DAILY_LIMIT_PER_IP = (ENV['VFC_APP_DAILY_LIMIT_PER_IP'] || 60).to_i
  APP_SIGNATURE_HEADER = 'X-VFC-App-Signature'
  # Generous, since phone clocks drift and downloads can sit in a queue.
  APP_SIGNATURE_WINDOW = 24.hours
  SIGNED_APP_DAILY_LIMIT = (ENV['VFC_SIGNED_APP_DAILY_LIMIT'] || 3000).to_i
  # Distinct messages one IP may fetch through page links in a day. Real
  # listeners stay under 60; a "download every link" browser extension
  # pulled 376 from one speaker's pages in an hour.
  PAGE_DAILY_LIMIT_PER_IP = (ENV['VFC_PAGE_DAILY_LIMIT_PER_IP'] || 150).to_i
  # Zip downloads ("download this page"): count and files per IP per day.
  ZIP_DAILY_LIMIT_PER_IP = (ENV['VFC_ZIP_DAILY_LIMIT_PER_IP'] || 5).to_i
  ZIP_FILES_DAILY_LIMIT_PER_IP = (ENV['VFC_ZIP_FILES_DAILY_LIMIT_PER_IP'] || 200).to_i
  OUR_HOSTS = %w(voicesforchrist.net voicesforchrist.org voixpourchrist.org
                 vocesparacristo.org vfc.io)
  # Set VFC_AUDIO_TOKEN_BIND_IP=false if binding tokens to the viewer's
  # network turns out to break real listeners.
  BIND_IP = ENV['VFC_AUDIO_TOKEN_BIND_IP'] != 'false'

  module_function

  def token(id, ip, now = Time.now)
    expires = now.to_i + TOKEN_TTL.to_i
    "#{expires}-#{signature(id, expires, ip)}"
  end

  # nil when the token is good, otherwise a short reason for the log.
  def token_problem(token, id, ip, now = Time.now)
    return 'missing' if token.blank?
    expires, sig = token.to_s.split('-', 2)
    return 'malformed' unless sig && expires =~ /\A\d+\z/
    return 'expired' if expires.to_i < now.to_i
    return 'bad_signature_or_ip' unless
      ActiveSupport::SecurityUtils.secure_compare(sig, signature(id, expires.to_i, ip))
    nil
  end

  def app_request?(user_agent)
    APP_USER_AGENT.match?(user_agent.to_s)
  end

  # Counts this request against the app's daily budgets and returns false
  # once either the total or this IP's share is used up.
  def app_allowance?(ip, today = Date.today)
    total  = bump("app:#{today}")
    per_ip = bump("app:#{today}:#{ip}")
    total <= APP_DAILY_LIMIT && per_ip <= APP_DAILY_LIMIT_PER_IP
  end

  # nil when the app's signature is good, otherwise a short reason for the log.
  def app_signature_problem(header, id, now = Time.now)
    return 'no_app_keys' if app_keys.empty?
    seconds, sig = header.to_s.split('-', 2)
    return 'malformed' unless sig && seconds =~ /\A\d+\z/
    return 'stale' if (now.to_i - seconds.to_i).abs > APP_SIGNATURE_WINDOW.to_i
    valid = app_keys.any? do |key|
      expected = OpenSSL::HMAC.hexdigest('SHA256', key, "#{id}:#{seconds}")[0, 32]
      ActiveSupport::SecurityUtils.secure_compare(sig, expected)
    end
    valid ? nil : 'bad_signature'
  end

  # Counts a signed app request; false once today's budget is used up.
  def signed_app_allowance?(today = Date.today)
    bump("signed_app:#{today}") <= SIGNED_APP_DAILY_LIMIT
  end

  # Counts a page-link fetch of message `id`. Repeat requests for the same
  # message (Range requests while playing, seeking, a second download) are
  # free; false once this IP has fetched its daily share of messages.
  def page_allowance?(ip, id, today = Date.today)
    seen = "page:#{today}:#{ip}:#{id}"
    count = "page:#{today}:#{ip}"
    return true if counters.exist?(seen)
    return false if (counters.read(count) || 0) >= PAGE_DAILY_LIMIT_PER_IP
    counters.write(seen, true, expires_in: 2.days)
    bump(count)
    true
  end

  # Counts a zip of `files` messages; false once this IP has used up its
  # daily zips or files. A refused zip doesn't count.
  def zip_allowance?(ip, files, today = Date.today)
    zips = "zip:#{today}:#{ip}"
    zipped = "zip_files:#{today}:#{ip}"
    return false if (counters.read(zips) || 0) >= ZIP_DAILY_LIMIT_PER_IP
    return false if (counters.read(zipped) || 0) + files > ZIP_FILES_DAILY_LIMIT_PER_IP
    bump(zips)
    bump(zipped, files)
    true
  end

  # True when the Referer is one of our sites (or the host being served,
  # which covers development).
  def our_referer?(referer, request_host)
    host = URI.parse(referer.to_s).host.to_s.downcase
    return false if host.empty?
    host == request_host.to_s.downcase ||
      OUR_HOSTS.any? { |ours| host == ours || host.end_with?(".#{ours}") }
  rescue URI::InvalidURIError
    false
  end

  def app_keys
    Array(Rails.application.credentials.audio_app_keys).map(&:to_s).reject(&:empty?)
  end

  # File-backed so every Passenger process shares the same counts.
  def counters
    @counters ||= if Rails.env.test?
      ActiveSupport::Cache::MemoryStore.new
    else
      ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp', 'cache', 'audio_gate'))
    end
  end

  def bump(key, amount = 1)
    counters.increment(key, amount, expires_in: 2.days) ||
      (counters.write(key, amount, expires_in: 2.days) && amount)
  end

  def signature(id, expires, ip)
    net = BIND_IP ? network(ip) : '*'
    OpenSSL::HMAC.hexdigest('SHA256', secret, "#{id}:#{expires}:#{net}")[0, 32]
  end

  def network(ip)
    addr = IPAddr.new(ip.to_s)
    addr.mask(addr.ipv4? ? 24 : 48).to_s
  rescue IPAddr::Error
    ip.to_s
  end

  def secret
    @secret ||= Rails.application.key_generator.generate_key('audio_gate')
  end
end
