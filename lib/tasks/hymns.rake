require 'csv'

namespace :hymns do
  

  desc "load hymns from previous csv"
  task :load => :environment do
    @input = ENV['file']
    CSV.foreach(@input) do |row|
      arr = row.to_a
      h = Hymn.new(:title => arr[0],:filename => arr[1])
      h.save!
      puts "Created hymn #{h.id} - #{h.title}"
    end
  end
end
