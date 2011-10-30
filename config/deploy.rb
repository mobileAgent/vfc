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
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
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

desc "After updating the code handle db yml and sphinx"
task :after_update_code, :roles => :app do
  buffer = YAML::load_file('config/database.yml');
  # purge unneeded configurations
  buffer.delete('test');
  buffer.delete('development');

  set :database_password do
    Capistrano::CLI.password_prompt "Database Password: "
  end
  buffer['production']['password'] = database_password
  put YAML::dump(buffer),"#{release_path}/config/database.yml",:mode=>0644

  # Clean up tmp and relink to shared for session and cache data
  run "rm -rf #{release_path}/tmp" # because it should not be in svn
  run "ln -nfs #{deploy_to}/shared/photos #{current_release}/public/photos"
  run "ln -nfs #{deploy_to}/shared/tmp #{release_path}/tmp"
  run "ln -nfs #{deploy_to}/shared/audio #{current_release}/public/audio"
  
  #sphinx.restart
  #create_symlinks
  # memcached.clear
  # update_configuration
end

desc "precompile the assets"
task :precompile_assets, :roles => :web, :except => { :no_release => true } do
  run "cd #{current_path}; rm -rf public/assets/*"
  run "cd #{current_path}; RAILS_ENV=production bundle exec rake assets:precompile"
end

namespace :sphinx do
  desc "Restart sphinx"
  task :restart do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:environment, "production")
    begin
      run "cd #{current_release}; RAILS_ENV=#{rails_env} #{rake} thinking_sphinx:stop"
    rescue
      puts "sphinx was not running, ok."
    end
    run "cd #{current_release}; RAILS_ENV=#{rails_env} #{rake} thinking_sphinx:configure"
    run "cd #{current_release}; RAILS_ENV=#{rails_env} #{rake} thinking_sphinx:index"
    run "cd #{current_release}; RAILS_ENV=#{rails_env} #{rake} thinking_sphinx:start"
  end
end
