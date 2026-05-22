ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.merge_timeout 3600
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/minitest'    # Rails 4.2+ uses Minitest as the test framework

# Fix "ThreadError: already initialized" in controller tests on Ruby 2.6+
# with Rails 4.2. ActionController::TestCase recycles the response object
# between requests by calling initialize again; Rails 4.2's response uses
# MonitorMixin, and Ruby 2.6+ raises if the monitor is re-initialized.
# Reset the monitor ivars before re-initializing.
if RUBY_VERSION >= "2.6.0" && Rails::VERSION::MAJOR < 5
  module ActionController
    class TestResponse < ActionDispatch::TestResponse
      def recycle!
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  end
end

#require 'capybara/rails'
#require 'capybara/poltergeist'
#Capybara.javascript_driver = :poltergeist

class ActiveSupport::TestCase
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
