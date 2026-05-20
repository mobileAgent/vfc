source 'https://rubygems.org'

gem 'rails', '3.2.22.5'

gem 'mysql2', '= 0.5.5'

# Streaming zip file output. Pinned to 1.x — 2.x requires Rails 6+.
# Use the released gem rather than the git ref to avoid pulling latest
# (which is 2.2.0 and incompatible with Rails 3.2).
gem 'zipline', '~> 1.0'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano', '2.15.5', require: false, group: :development

# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
gem 'nokogiri', '~> 1.13.10'  # last line supporting Ruby 2.6
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2'  # 5.x+ requires Rails 4+

# Strong parameters is the default in rails4
gem 'strong_parameters'
gem "nilify_blanks"

# Only use the snowman stuff on broken browsers
# gem 'utf8_enforcer_workaround'

# Turbolinks is the default in rails4. Pinned: 5.x reorganized as ES
# modules and the `//= require turbolinks` Sprockets directive used in
# app/assets/javascripts/application.js no longer resolves.
gem 'turbolinks', '~> 2.5.4'
gem 'jquery-turbolinks', '~> 2.1'

gem 'will_paginate',
  :git => 'https://github.com/mislav/will_paginate.git'
gem 'ffi', '~> 1.15.5'
gem 'bigdecimal', '~> 1.4.4'

gem 'thinking-sphinx', '~> 2.1'
  
#gem 'acts_as_taggable_on_steroids'
gem 'acts_as_taggable_on_steroids',
  :git     => 'https://github.com/mobileAgent/acts_as_taggable_on_steroids.git'

gem 'rdiscount'  
gem 'ruby-mp3info',
   :git => 'https://github.com/cball/ruby-mp3info.git'

gem 'execjs'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.5', require: 'bcrypt'

# To use Jbuilder templates for JSON
# gem 'jbuilder'
   
gem 'exception_notification', '~> 4.0.0'
# (actionmailer pulled in by rails; no need to declare directly)

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'simplecov', :require => false
  gem "mocha", '~> 1.16', :require => false  # 2.x+ requires Minitest; 3.x conflicts with Rails 3.2's test-unit

  # acceptance test framework
  #  gem "capybara"
  #  gem "poltergeist"
  
  # js testing framework
  #  gem "teaspoon"
  
  gem 'guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'guard-test'

end

group :test do
  gem 'rspec-rails',       '~> 3.9.0'
  gem 'capybara',          '~> 2.18.0'
  gem 'database_cleaner',  '~> 1.8.5'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'test-unit',         '~> 2.5'  # mocha 1.x doesn't integrate with test-unit 3.x hooks; vfc's legacy suite uses this combo
end

# gem 'rack-mini-profiler', :group => :development

# Better irb - bundle exec pry -r ./config/environment
# gem 'pry', :group => :development
# gem 'pry-doc', :group => :development
