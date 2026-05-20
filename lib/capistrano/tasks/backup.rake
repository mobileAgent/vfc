namespace :db do
  desc "Backup the remote production database to backups/ on the deployer machine"
  task :backup do
    on roles(:db), primary: true do
      # Read credentials from the server's shared config — production
      # credentials never leave the server.
      db_yml = capture("cat #{shared_path}/config/database.yml")
      db_config = YAML.safe_load(db_yml, aliases: true)["production"]

      filename    = "#{fetch(:application)}.dump.#{Time.now.to_i}.sql.bz2"
      remote_path = "/tmp/#{filename}"

      info "Dumping #{db_config['database']} to #{remote_path}"
      execute "mysqldump -u #{db_config['username']} " \
              "--password=#{db_config['password']} " \
              "#{db_config['database']} | bzip2 -c > #{remote_path}"

      run_locally do
        execute :mkdir, "-p", "backups"
      end

      info "Downloading #{remote_path} -> backups/#{filename}"
      download! remote_path, "backups/#{filename}"

      execute "rm #{remote_path}"
    end
  end
end

# Always back up before running migrations
before "deploy:migrate", "db:backup"
