# config valid for current version and patch releases of Capistrano
lock "~> 3.17"

set :application, "vfc"
set :repo_url,    "https://github.com/mobileAgent/vfc.git"

# Default branch; override with `BRANCH=foo cap production deploy` if needed
set :branch, ENV.fetch("BRANCH", "master")

# Deploy target on the server
set :deploy_to, "/var/apps/#{fetch(:application)}"

# How many old releases to retain in /var/apps/vfc/releases/
set :keep_releases, 3

# rbenv configuration — matches the server-side install at /opt/rbenv
# with Ruby 2.7.8. Bump when you bump the app's Ruby version.
set :rbenv_type,     :system
set :rbenv_path,     "/opt/rbenv"
set :rbenv_ruby,     "2.7.8"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# Bundler parallelism
set :bundle_jobs, 4

# Directories symlinked from /var/apps/vfc/shared/ into each release.
# Anything that should persist across deploys (logs, uploads, pid files,
# the audio archive) goes here.
append :linked_dirs,
  "log",
  "tmp/pids",
  "tmp/cache",
  "tmp/sockets",
  "public/photos"

# Files symlinked from shared/ into each release. These are the only
# real secrets and they are NEVER committed to the repo:
#   - config/database.yml  : production DB credentials
#   - config/master.key    : the key that decrypts credentials.yml.enc
# NOTE: config/credentials.yml.enc is intentionally NOT linked. It is an
# *encrypted* file that is committed to git and ships inside each release,
# so it always matches the codebase. Linking it from shared/ caused the
# release copy to be replaced by a stale shared copy that no longer matched
# master.key -> "InvalidMessage / invalid base64" at boot.
append :linked_files, "config/database.yml", "config/master.key"

# Default value for keeping the SSH connection open during long tasks
set :ssh_options, {
  forward_agent: true,
  keepalive: true,
  keepalive_interval: 30
}

namespace :deploy do
  desc "Restart Passenger by touching tmp/restart.txt"
  task :restart do
    on roles(:app) do
      execute "touch #{release_path}/tmp/restart.txt"
    end
  end

  # Restart Passenger after every successful publish
  after :publishing, :restart
end
