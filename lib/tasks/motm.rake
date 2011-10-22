require 'csv'

namespace :motm do

  desc "load motm from previous csv"
  task :load => :environment do
    @input = ENV['file']
    CSV.foreach(@input) do |row|
      arr = row.to_a
      am = AudioMessage.find(:first, :conditions => ["filename like ?","%#{arr[0]}%"])
      if am
        motm = Motm.create(:audio_message_id => am.id, :created_at => Date.parse(arr[1]))
        puts "Created motm #{motm.inspect}"
      end
    end
  end
end
