require 'csv'

namespace :notes do

  desc "load notes from csv"
  task :load => :environment do
    @input = ENV['file']
    CSV.foreach(@input) do |row|
      arr = row.to_a
      n = Note.create(:filesize => arr[0].to_i,
                      :filename => arr[1],
                      :title => arr[2].gsub(/\. /,'.'),
                      :speaker_id => arr[3].to_i)
      a = AudioMessage.find(:first, :conditions => ['speaker_id = ? and title like ? and note_id is null',n.speaker_id,n.title[0..12].gsub(/,.*/,'')+"%"])
      if a
        a.note_id = n.id
        a.save!
        puts "Added note #{n.id} to audio #{a.id}"
      else
        puts "No audio found for note #{n.id} using title #{n.title}"
      end
    end
  end
end
