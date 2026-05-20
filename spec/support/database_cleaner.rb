require 'database_cleaner/active_record'

RSpec.configure do |config|
  # Wipe the test database once before the suite to be sure we start clean.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # Default to fast transactional cleanup per example.
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Feature specs run Capybara, which uses a separate connection in JS
  # drivers. Use truncation there so data is visible across connections.
  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) { DatabaseCleaner.start }
  config.after(:each)  { DatabaseCleaner.clean }
end
