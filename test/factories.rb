Factory.define :place do |u|
  u.name "Zendia"
  u.cc "ZN"
end

Factory.define :speaker do |u|
  u.last_name "Last#{rand(1000)}"
  u.first_name "A"
  u.middle_name "B"
  u.bio "Was a great man, truly."
end

Factory.define :language do |u|
  u.name "Zendian"
end

Factory.define :audio_message do |u|
  u.title "Message Title"
  u.subj "The Subject"
  u.groupmsg "V-#{rand(1000)}-#{rand(99)}"
  u.filename "FOLDER/file.mp3"
  u.duration "12345"
  u.filesize "54321"
  u.event_date Date.parse("1986-09-06")
end

Factory.define :motm do |u|
  u.audio_message Factory(:audio_message)
end

