ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'capybara/rspec'

# Load every file under spec/support/ before specs run.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # We use DatabaseCleaner instead of transactional fixtures so that
  # Capybara feature specs see committed data across threads.
  config.use_transactional_fixtures = false

  # Infer spec type (:model, :controller, :feature, ...) from the file path
  # under spec/, so we don't have to write `type: :feature` on every spec.
  config.infer_spec_type_from_file_location!
end
