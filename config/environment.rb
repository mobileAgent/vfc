# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  config.gem 'clearance'
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx'
  config.gem 'formtastic'

  config.time_zone = 'UTC'
end
