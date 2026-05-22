source 'https://rubygems.org'

gem 'rails', '5.2.8.1'

# Strong parameters is now the default, but Rails 4 ships the
# protected_attributes gem as a back-compat layer so your existing
# attr_accessible code keeps working. Keep this for now; remove during
# the 5.x leg when you actually convert controllers to strong params.
# gem 'protected_attributes'

# Asset pipeline gems bump in lockstep with Rails 4.2
gem 'sass-rails',   '~> 5.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'  # 4.x line works with Rails 4.2

# mysql2 — Rails 4.2's adapter accepts ~> 0.3.13 OR 0.4.x.
# Drop the version pin entirely and let bundler pick.
gem 'mysql2'

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

gem 'jquery-ui-rails'

# Strong parameters is the default in rails4
# gem 'strong_parameters'
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

gem 'actionpack-page_caching'
gem 'thinking-sphinx', '~> 4.4.1'
gem 'acts-as-taggable-on', '~> 5.0'

gem 'rdiscount'  
gem 'ruby-mp3info',
   :git => 'https://github.com/cball/ruby-mp3info.git'

gem 'execjs'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # gem 'sass-rails',   "~> 3.2.3"
  # gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end

# To use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'   # was bcrypt-ruby

# To use Jbuilder templates for JSON
# gem 'jbuilder'
   
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

  gem 'rspec-rails',      '~> 4.1.0'   # 4.x supports Rails 5+
  gem 'capybara',         '~> 3.36.0'  # rack 2.x constraint now satisfied
  gem 'nokogiri', '~> 1.13.10'  # last line supporting Ruby 2.6
  gem 'database_cleaner', '~> 1.8.5'   # 1.x still fine; 2.x split is optional
  gem 'factory_girl_rails'             # still works; rename later
  gem 'launchy'

  # NEW: Rails 5 moved render/assigns/assert_template out of core for
  # controller specs. If you don't have controller specs yet you can skip,
  # but include it now for when you do.
  gem 'rails-controller-testing'
  
end
