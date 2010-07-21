set :application, "vfc"
set :repository,  "git@github.com:mobileAgent/vfc.git"
set :scm, :git
set :branch, "master"

set :server_name, "voicesforchrist.org"
role :web, "#{server_name}"
role :app, "#{server_name}"
role :db,  "#{server_name}", :primary => true

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
