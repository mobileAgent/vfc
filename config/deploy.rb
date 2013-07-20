require 'yaml'
require 'bundler/capistrano'

set :application, "vfc"
set :repository,  "git@github.com:mobileAgent/vfc.git"
set :scm, :git
set :branch, "master"
set :user, 'vfcnet'
set :group, 'vfcnet'
set :deploy_to, "/var/apps/#{application}"
set :use_sudo, false

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
  filename = "#{application}.dump.#{Time.now.strftime("%Y%m%d-%H%M")}.sql.bz2"
  file = "/tmp/#{filename}"
  on_rollback { run "rm /tmp/#{filename}" }
  set :database_password do
    Capistrano::CLI.password_prompt "Production Database Password: "
  end
  db = YAML::load_file("config/database.yml")
  run "mysqldump -u #{db['production']['username']} --password=#{database_password} #{db['production']['database']} | bzip2 -c > #{file}"  do |ch, stream, data|
    puts data
  end
  `mkdir -p #{File.dirname(__FILE__)}/../backups/`
  get file, "backups/#{filename}"
  #delete file
  run "rm /tmp/#{filename}"
end

desc "After updating the code handle db yml and sphinx"
after 'deploy:update_code', :config_setup
task :config_setup, :roles => :app do
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
  run "ln -nfs #{deploy_to}/shared/writings #{current_release}/public/writings"
  run "ln -nfs #{deploy_to}/shared/notes #{current_release}/public/notes"
  
  # create_symlinks
  # memcached.clear
  # update_configuration
  sphinx.rebuild
  precompile_assets
end

desc "precompile the assets"
task :precompile_assets, :roles => :web, :except => { :no_release => true } do
  run "cd #{current_release}; rm -rf public/assets/*"
  run "cd #{current_release}; RAILS_ENV=production bundle exec rake assets:precompile"
end

namespace :sphinx do
  desc "Restart sphinx"
  task :rebuild do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:environment, "production")
    begin
      run "cd #{current_release}; RAILS_ENV=#{rails_env} #{rake} ts:conf"
      run "cd #{current_release}; RAILS_ENV=#{rails_env} #{rake} ts:rebuild"
    rescue
      puts "sphinx rebuild failed - #{$!}"
    end
  end
end
