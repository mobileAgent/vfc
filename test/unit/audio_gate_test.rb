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

  def test_app_allowance_resets_each_day
    AudioGate::APP_DAILY_LIMIT_PER_IP.times { AudioGate.app_allowance?("10.9.9.9", Date.new(2026, 10, 1)) }
    assert !AudioGate.app_allowance?("10.9.9.9", Date.new(2026, 10, 1))
    assert AudioGate.app_allowance?("10.9.9.9", Date.new(2026, 10, 2))
  end
end
