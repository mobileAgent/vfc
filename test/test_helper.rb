ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'capybara/rails'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

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
