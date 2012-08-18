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
    hidden false
    bio "Was a great man, truly."
  end

  factory :language do 
    name "English"
    cc "en"
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
    publish true
    language FactoryGirl.create(:language)
    place FactoryGirl.create(:place)
    speaker FactoryGirl.create(:speaker)
    event_date Date.parse("1986-09-06")
  end

  factory :motm do 
    audio_message FactoryGirl.create(:audio_message)
  end

  factory :blocked_host do
    ip_address "123.123.123.123"
  end

  factory :user do
    sequence :email do |n|
      "user#{n*2}@example.com"
    end
    sequence :name do |n|
      "username#{n*2}"
    end
    activated true
    last_visit Date.today - 30
    password "secret"
    admin false
  end

  factory :hymn do
    sequence :title do
      "Message Title #{n}"
    end
    filename "HYMN/hymn.mp3"
  end
    
  
end
