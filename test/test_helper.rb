ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end


# This does not work exactly right, but it does
# error out on missing translations from the default_locale (:en)
# which is what we need
module I18n
  def self.just_raise_that_exception(*args)
    raise args.first
  end
end
 
I18n.exception_handler = :just_raise_that_exception
