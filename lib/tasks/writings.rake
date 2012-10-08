require 'csv'

namespace :writings do

  desc "load writings from csv"
  task :load => :environment do
    @input = ENV['file']
    CSV.foreach(@input) do |row|
      arr = row.to_a
      filename = arr[0]
      title = arr[1]
      last_name = arr[2]
      first_name = arr[3]
      length = arr[4]
      s = Speaker.find(:first, :conditions => ['last_name = ? and first_name = ?',last_name,first_name])
      if s.nil?
        s = Speaker.create(:last_name => last_name, :first_name => first_name)
        puts "Created speaker #{s.full_name}/#{s.id}"
      end
      v = Writing.new(:title => title,:filename => filename, :speaker_id => s.id)
      v.save!
      puts "Created writing #{v.id} - #{v.title}"
    end
  end
end
