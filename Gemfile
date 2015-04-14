source 'https://rubygems.org'

gem 'rails', '3.2.14'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

# Streaming zip file output
gem 'zipline', :git => 'git://github.com/fringd/zipline.git'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano', '2.15.5', require: false, group: :development

# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Strong parameters is the default in rails4
gem 'strong_parameters'
gem "nilify_blanks"

# Only use the snowman stuff on broken browsers
gem 'utf8_enforcer_workaround'

# Turbolinks is the default in rails4
gem 'turbolinks'
gem 'jquery-turbolinks'

gem 'will_paginate',
  :git => 'git://github.com/mislav/will_paginate.git'

gem 'thinking-sphinx', '~> 2.1'
  
#gem 'acts_as_taggable_on_steroids'
gem 'acts_as_taggable_on_steroids',
  :git     => 'git://github.com/mobileAgent/acts_as_taggable_on_steroids.git'

gem 'rdiscount'  
gem 'ruby-mp3info',
   :git => 'git://github.com/cball/ruby-mp3info.git'

gem 'execjs'
gem 'therubyracer'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end

# To use ActiveModel has_secure_password
 gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'
   
gem 'exception_notification'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'thin'
  gem 'webrat'
  gem 'simplecov', :require => false
  gem "mocha", :require => false

  # acceptance test framework
  #  gem "capybara"
  #  gem "poltergeist"
  
  # js testing framework
  #  gem "teaspoon"
  
  gem 'guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'guard-test'

end

gem 'factory_girl_rails', :group => :test
gem 'ruby-prof', :group => :test
gem 'test-unit', :group => :test
gem 'rack-mini-profiler', :group => :development

# Better irb - bundle exec pry -r ./config/environment
gem 'pry', :group => :development
gem 'pry-doc', :group => :development
