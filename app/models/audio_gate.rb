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
module AudioGate
  TOKEN_TTL = 24.hours
  APP_USER_AGENT = /\ADart\//
  APP_DAILY_LIMIT = (ENV['VFC_APP_DAILY_LIMIT'] || 500).to_i
  APP_DAILY_LIMIT_PER_IP = (ENV['VFC_APP_DAILY_LIMIT_PER_IP'] || 60).to_i
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

  # File-backed so every Passenger process shares the same counts.
  def counters
    @counters ||= if Rails.env.test?
      ActiveSupport::Cache::MemoryStore.new
    else
      ActiveSupport::Cache::FileStore.new(Rails.root.join('tmp', 'cache', 'audio_gate'))
    end
  end

  def bump(key)
    counters.increment(key, 1, expires_in: 2.days) ||
      (counters.write(key, 1, expires_in: 2.days) && 1)
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
