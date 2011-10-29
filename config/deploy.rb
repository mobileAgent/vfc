require 'yaml'
require 'bundler/capistrano'

set :application, "vfc"
set :repository,  "git@github.com:mobileAgent/vfc.git"
set :scm, :git
set :branch, "master"
set :user, 'vfcnet'
set :group, 'vfcnet'
set :deploy_to, "/var/apps/#{application}"

set :server_name, "voicesforchrist.net"
role :web, "#{server_name}"
role :app, "#{server_name}"
role :db,  "#{server_name}", :primary => true


set :db_username, "vfcowner"

# How much to keep on a cleanup task
set :keep_releases, 3


# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "Backup the remote production database"
task :backup, :roles => :db, :only => { :primary => true } do
  filename = "#{application}.dump.#{Time.now.to_i}.sql.bz2"
  file = "/tmp/#{filename}"
  on_rollback { run "rm /tmp/#{filename}" }
  db = YAML::load_file("config/database.yml")
  run "mysqldump -u #{db['production']['username']} --password=#{db['production']['password']} #{db['production']['database']} | bzip2 -c > #{file}"  do |ch, stream, data|
    puts data
  end
  `mkdir -p #{File.dirname(__FILE__)}/../backups/`
  get file, "backups/#{filename}"
  #delete file
  run "rm /tmp/#{filename}"
end

desc "Do sphinx stuff on new app"
task :after_update_code do
  sphinx.restart
  create_symlinks
  # memcached.clear
  # update_configuration
end

desc "Symlink in the shared stuff"
task :create_symlinks do
  as = fetch(:runner, "app")
  via = fetch(:run_method, :run)
  invoke_command("cd #{current_release} && ln -s #{deploy_to}/shared/photos ./public/photos", :via => via, :as => as)        
end

namespace :sphinx do
  desc "Restart sphinx"
  task :restart do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:environment, "development")
    begin
      run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} thinking_sphinx:stop"
    rescue
      puts "sphinx was not running, ok."
    end
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} thinking_sphinx:configure"
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} thinking_sphinx:index"
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} thinking_sphinx:start"
  end
end
