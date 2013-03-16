require 'csv'

namespace :vfc do

  desc "import new records"
  task :import => :environment do

    include VfcConverter
    
    @file = ENV['file']
    if @file.nil?
      puts "You must supply file argument"
    else
    
      CSV.foreach(@file) do |row|
        arr = row.to_a
        next if arr.include?("SUBJECT")
        am = AudioMessage.create(
                                 :title => arr[0] || '(missing title)',
                                 :subj => arr[1],
                                 :groupmsg => nil,
                                 :speaker => converted_speaker(arr[2]),
                                 :event_date => converted_event_date(arr[3]),
                                 # :download => arr[4],
                                 :publish => arr[5],
                                 :filename => arr[6],
                                 :language => converted_language(arr[7]),
                                 :created_at => arr[8],
                                 # :updated_at => arr[9],
                                 :duration => converted_duration(arr[10]),
                                 :filesize => arr[11],
                                 :place => place_locator(arr[12])
                                 )
      end
    end
  end
end
    
