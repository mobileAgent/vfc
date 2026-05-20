# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# SCM
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Per-app Ruby via rbenv on the server
require "capistrano/rbenv"

# `bundle install` on the server, with the right Ruby/binstubs
require "capistrano/bundler"

# Rails-specific helpers
require "capistrano/rails/migrations"
require "capistrano/rails/assets"

# Load custom rake tasks under lib/capistrano/tasks/
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
