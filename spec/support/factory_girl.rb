RSpec.configure do |config|
  # Use unprefixed `create(:event)` / `build(:event)` in specs instead of
  # `FactoryGirl.create(:event)`.
  config.include FactoryGirl::Syntax::Methods
end
