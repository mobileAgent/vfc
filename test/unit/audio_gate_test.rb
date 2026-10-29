require 'test_helper'

class AudioGateTest < ActiveSupport::TestCase

  def setup
    AudioGate.counters.clear
  end

  def test_token_round_trip
    t = AudioGate.token(42, "10.1.2.3")
    assert_nil AudioGate.token_problem(t, 42, "10.1.2.3")
  end

  def test_token_works_across_the_same_slash_24
    t = AudioGate.token(42, "10.1.2.3")
    assert_nil AudioGate.token_problem(t, 42, "10.1.2.250")
  end

  def test_token_rejected_from_another_network
    t = AudioGate.token(42, "10.1.2.3")
    assert_equal "bad_signature_or_ip", AudioGate.token_problem(t, 42, "10.1.3.3")
  end

  def test_token_rejected_for_another_message
    t = AudioGate.token(42, "10.1.2.3")
    assert_equal "bad_signature_or_ip", AudioGate.token_problem(t, 43, "10.1.2.3")
  end

  def test_token_expires
    t = AudioGate.token(42, "10.1.2.3", Time.now - 25.hours)
    assert_equal "expired", AudioGate.token_problem(t, 42, "10.1.2.3")
  end

  def test_missing_and_malformed_tokens
    assert_equal "missing", AudioGate.token_problem(nil, 42, "10.1.2.3")
    assert_equal "malformed", AudioGate.token_problem("garbage", 42, "10.1.2.3")
    assert_equal "malformed", AudioGate.token_problem("abc-def", 42, "10.1.2.3")
  end

  def test_tampered_expiry_rejected
    expires, sig = AudioGate.token(42, "10.1.2.3").split('-', 2)
    t = "#{expires.to_i + 86400}-#{sig}"
    assert_equal "bad_signature_or_ip", AudioGate.token_problem(t, 42, "10.1.2.3")
  end

  def test_app_user_agent
    assert AudioGate.app_request?("Dart/3.4 (dart:io)")
    assert AudioGate.app_request?("Dart/3.10 (dart:io)")
    assert !AudioGate.app_request?("Mozilla/5.0 Dart/3.4")
    assert !AudioGate.app_request?(nil)
  end

  def test_app_allowance_per_ip_budget
    AudioGate::APP_DAILY_LIMIT_PER_IP.times do
      assert AudioGate.app_allowance?("10.9.9.9")
    end
    assert !AudioGate.app_allowance?("10.9.9.9"), "IP over its daily budget"
    assert AudioGate.app_allowance?("10.9.9.10"), "other IPs unaffected"
  end

  def test_app_allowance_total_budget
    AudioGate::APP_DAILY_LIMIT.times do |i|
      assert AudioGate.app_allowance?("10.8.#{i / 250}.#{i % 250}")
    end
    assert !AudioGate.app_allowance?("10.7.7.7"), "daily total spent"
  end

  def test_app_signature_matches_the_app
    # Same vector as the mobile app's test/app_signature_test.dart
    AudioGate.stubs(:app_keys).returns(['test-key'])
    assert_nil AudioGate.app_signature_problem(
      '1792938404-ce946b60a7d7e53f0107ecf0e533056c', 127617, Time.at(1792938404))
  end

  def test_app_signature_accepts_any_listed_key
    AudioGate.stubs(:app_keys).returns(['new-key', 'old-key'])
    assert_nil AudioGate.app_signature_problem(app_signature('old-key', 42), 42)
    assert_nil AudioGate.app_signature_problem(app_signature('new-key', 42), 42)
  end

  def test_app_signature_rejections
    AudioGate.stubs(:app_keys).returns(['k'])
    assert_equal 'bad_signature', AudioGate.app_signature_problem(app_signature('other', 42), 42)
    assert_equal 'bad_signature', AudioGate.app_signature_problem(app_signature('k', 43), 42)
    assert_equal 'stale', AudioGate.app_signature_problem(app_signature('k', 42, Time.now - 25.hours), 42)
    assert_equal 'stale', AudioGate.app_signature_problem(app_signature('k', 42, Time.now + 25.hours), 42)
    assert_equal 'malformed', AudioGate.app_signature_problem('nonsense', 42)
  end

  def test_app_signature_without_configured_keys
    AudioGate.stubs(:app_keys).returns([])
    assert_equal 'no_app_keys', AudioGate.app_signature_problem(app_signature('k', 42), 42)
  end

  def test_signed_app_allowance_budget
    AudioGate::SIGNED_APP_DAILY_LIMIT.times { assert AudioGate.signed_app_allowance? }
    assert !AudioGate.signed_app_allowance?
  end

  def test_page_allowance_counts_distinct_messages
    AudioGate::PAGE_DAILY_LIMIT_PER_IP.times do |id|
      assert AudioGate.page_allowance?("10.5.5.5", id)
      assert AudioGate.page_allowance?("10.5.5.5", id), "repeat fetch of the same message is free"
    end
    assert !AudioGate.page_allowance?("10.5.5.5", 99999), "new message over the limit"
    assert AudioGate.page_allowance?("10.5.5.5", 0), "already-fetched message still plays"
    assert AudioGate.page_allowance?("10.5.5.6", 99999), "other IPs unaffected"
  end

  def test_zip_allowance_limits_zips_and_files
    AudioGate::ZIP_DAILY_LIMIT_PER_IP.times { assert AudioGate.zip_allowance?("10.4.4.4", 1) }
    assert !AudioGate.zip_allowance?("10.4.4.4", 1), "too many zips"

    assert AudioGate.zip_allowance?("10.4.4.5", AudioGate::ZIP_FILES_DAILY_LIMIT_PER_IP - 10)
    assert !AudioGate.zip_allowance?("10.4.4.5", 11), "too many files"
    assert AudioGate.zip_allowance?("10.4.4.5", 10), "a refused zip doesn't use up the budget"
  end

  def test_our_referer
    assert AudioGate.our_referer?("https://voicesforchrist.org/welcome/search?q=x", "voicesforchrist.org")
    assert AudioGate.our_referer?("https://www.vocesparacristo.org/speakers/1", "voicesforchrist.net")
    assert AudioGate.our_referer?("http://localhost:3001/speakers/1", "localhost")
    assert !AudioGate.our_referer?("https://evil.example/voicesforchrist.org", "voicesforchrist.org")
    assert !AudioGate.our_referer?("https://notvoicesforchrist.org/", "voicesforchrist.org")
    assert !AudioGate.our_referer?(nil, "voicesforchrist.org")
    assert !AudioGate.our_referer?("not a url at all ::", "voicesforchrist.org")
  end

  def test_app_allowance_resets_each_day
    AudioGate::APP_DAILY_LIMIT_PER_IP.times { AudioGate.app_allowance?("10.9.9.9", Date.new(2026, 10, 1)) }
    assert !AudioGate.app_allowance?("10.9.9.9", Date.new(2026, 10, 1))
    assert AudioGate.app_allowance?("10.9.9.9", Date.new(2026, 10, 2))
  end

  private

  def app_signature(key, id, at = Time.now)
    "#{at.to_i}-#{OpenSSL::HMAC.hexdigest('SHA256', key, "#{id}:#{at.to_i}")[0, 32]}"
  end
end
