require 'csv'

namespace :videos do

  desc "load videos from csv"
  task :load => :environment do
    @input = ENV['file']
    CSV.foreach(@input) do |row|
      arr = row.to_a
      title = arr[0]
      filename = arr[1]
      last_name = arr[2]
      first_name = arr[3]
      length = arr[4]
      s = Speaker.find(:first, :conditions => ['last_name = ? and first_name = ?',last_name,first_name])
      if s.nil?
        s = Speaker.create(:last_name => last_name, :first_name => first_name)
        puts "Created speaker #{s}"
      end
      v = Video.new(:title => title,:filename => filename, :speaker_id => s.id, :duration => length)
      v.save!
      puts "Created video #{v.id} - #{v.title}"
    end
  end
end
