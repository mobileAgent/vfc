source 'https://rubygems.org'

gem 'rails', '6.1.7.10'
gem 'rake'


# Asset stack — keep Sprockets, skip Webpacker.
# Rails 6 wants Webpacker as a default but you can opt out
# (much less work right now than rewriting your JS).
gem 'sass-rails', '>= 6'
gem 'jquery-rails'
gem 'logger'
gem 'concurrent-ruby', '< 1.3.5'
gem 'jquery-ui-rails'

# Strong parameters is the default in rails4
# gem 'strong_parameters'
gem "nilify_blanks"

gem 'turbolinks', '~> 5.2'
gem 'jquery-turbolinks', '~> 2.1'
gem 'will_paginate', '~> 3.3'
gem 'ffi', '~> 1.15.5'
gem 'actionpack-page_caching', '~> 1.2'
gem 'thinking-sphinx', '~> 5.6'
gem 'acts-as-taggable-on', '~> 9.0.1'
gem 'rdiscount'  
gem 'ruby-mp3info',
   :git => 'https://github.com/cball/ruby-mp3info.git'

gem 'execjs'
gem 'coffee-rails', '~> 5.0'

gem 'mysql2'

# Streaming zip file output. Pinned to 1.x — 2.x requires Rails 6+.
# Use the released gem rather than the git ref to avoid pulling latest
# (which is 2.2.0 and incompatible with Rails 3.2).
gem 'zipline'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Deploy with Capistrano (3.x)
group :development do
  gem 'capistrano',         '~> 3.17'
  gem 'capistrano-rails',   '~> 1.6'
  gem 'capistrano-bundler', '~> 2.1'
  gem 'capistrano-rbenv',   '~> 2.2'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # gem 'sass-rails',   "~> 3.2.3"
  # gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end

# To use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'   # was bcrypt-ruby

gem 'exception_notification', '~> 4.0.0'
# (actionmailer pulled in by rails; no need to declare directly)

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'simplecov', :require => false
  gem "mocha", '~> 2.1', :require => false
  gem 'guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'guard-test'
end

group :test do

  gem 'rspec-rails',      '~> 4.1'   # 4.x supports Rails 5+
  gem 'capybara',         '~> 3.36.0'  # rack 2.x constraint now satisfied
  gem 'nokogiri'
  gem 'database_cleaner-active_record', '~> 2.0'  # 2.x split
  gem 'factory_girl_rails'             # still works; rename later
  gem 'launchy'

  # NEW: Rails 5 moved render/assigns/assert_template out of core for
  # controller specs. If you don't have controller specs yet you can skip,
  # but include it now for when you do.
  gem 'rails-controller-testing'
  
end
