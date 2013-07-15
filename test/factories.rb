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
    sequence :title do |n|
      "Message Title #{n}"
    end
    sequence :subj do |n|
      "The Subject #{n}"
    end
    sequence :groupmsg do |n|
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
    note nil
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
    place_editor false
    speaker_editor false
    audio_message_editor false
    video_editor false
    tags_editor false
  end

  factory :hymn do
    sequence :title do |n|
      "Message Title #{n}"
    end
    filename "HYMN/hymn.mp3"
  end

  factory :video do
    sequence :title do |n|
      "Video Title #{n}"
    end
    filename "VIDEO/video.mp4"
    speaker FactoryGirl.create(:speaker)
  end
    
 factory :writing do
    sequence :title do |n|
      "Article Title #{n}"
    end
    filename "WRITING/writing.pdf"
    speaker FactoryGirl.create(:speaker)
  end

  factory :note do
    sequence :title do |n|
      "Note Title #{n}"
    end
    filename "NOTE/note.pdf"
    speaker FactoryGirl.create(:speaker)
  end
   
end
