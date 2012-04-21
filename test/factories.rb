FactoryGirl.define do
  
  factory :place do
    name "Zendia"
    cc "ZN"
  end

  factory :speaker do
    sequence :last_name do |n|
      "Last#{n}"
    end
    first_name "A"
    middle_name "B"
    bio "Was a great man, truly."
  end

  factory :language do 
    name "Zendian"
  end

  factory :audio_message do
    sequence :title do
      "Message Title #{n}"
    end
    sequence :subj do
      "The Subject #{n}"
    end
    sequence :groupmsg do
      "V-#{n}-#{n}"
    end
    filename "FOLDER/file.mp3"
    duration "12345"
    filesize "54321"
    speaker FactoryGirl.create(:speaker)
    event_date Date.parse("1986-09-06")
  end

  factory :motm do 
    audio_message FactoryGirl.create(:audio_message)
  end

end
