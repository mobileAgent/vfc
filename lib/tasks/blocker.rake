namespace :blocker do
  desc "load data from file"
  task :load => :environment do
    @input = ENV['file']
    IO.readlines(@input).each do |line|
      BlockedHost.create(:ip_address => line.chomp)
    end
  end
end
