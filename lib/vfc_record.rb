# This model is only used to convert the old records
# When migrating from the old batch system to the 
# new rails3 system. Seed data should already
# be loaded (rake db:seeds) before converting
# 
# At the time of migration the old table structure is 
# as follows (speaker_id, obs_call, obs_grouping, notes_id) are unused
# 
# | id           | int(11)      | NO   | PRI | NULL                | auto_increment |
# | msg          | varchar(128) | YES  |     | NULL                |                |
# | changed      | tinyint(1)   | YES  |     | NULL                |                |
# | speaker      | varchar(128) | YES  |     | NULL                |                |
# | subj         | varchar(128) | YES  |     | NULL                |                |
# | groupmsg     | varchar(16)  | YES  | MUL | NULL                |                |
# | date         | varchar(16)  | YES  |     | NULL                |                |
# | obs_call     | varchar(16)  | YES  |     | NULL                |                |
# | obs_grouping | varchar(16)  | YES  |     | NULL                |                |
# | add_date     | timestamp    | NO   |     | 0000-00-00 00:00:00 |                |
# | download     | tinyint(1)   | YES  |     | NULL                |                |
# | publish      | tinyint(1)   | YES  |     | NULL                |                |
# | filename     | varchar(512) | YES  |     | NULL                |                |
# | notes_id     | int(11)      | YES  |     | NULL                |                |
# | language     | varchar(16)  | YES  |     | NULL                |                |
# | speaker_id   | int(11)      | YES  |     | NULL                |                |
# | change_date  | timestamp    | NO   |     | 0000-00-00 00:00:00 |                |
# | duration     | varchar(16)  | YES  |     | NULL                |                |
# | filesize     | int(11)      | YES  |     | NULL                |                |
# | place        | varchar(16)  | YES  |     | NULL                |                |
class VfcRecord < ActiveRecord::Base

  self.table_name = "vfc"

  # include VfcConverter

  def self.instance_method_already_implemented?(method_name)
    return true if (method_name == 'changed?' || method_name == 'changed')
    super
  end

  def converted_place
    {"Turkey Hill" => "Turkey Hill Camp",
      "Story ?[Bb]ook" => "Storybook Lodge",
      "Ramseur" => "Ramseur, North Carolina",
      "Wilmington" => "Wilmington, North Carolina",
      "Dallas" => "Dallas, Texas",
      "West Virginia" => "West Virginia",
      "St.Louis" => "St. Louis, Missouri",
      "Omaha" => "Omaha, Nebraska",
      "Spanish Wells" => "Spanish Wells, Bahamas",
      "Hollywood Bible" => "Hollywood, Florida",
      "Camp Horizon" => "Camp Horizon, Florida",
      "Camp Living Water" => "Camp Living Water",
      "Galilee Bible" => "Galilee Bible Camp",
      "Rockville" => "Rockville, Maryland",
      "Durham" => "Durham, North Carolina",
      "Raleigh" => "Raleigh, North Carolina",
      "Vancouver" => "Vancouver, BC, Canada",
      "Shannon Hills Chpl" => "Shannon Hills, North Carolina",
      "Toronto" => "Toronto, Canada",
      "Park Of The Palms" => "Park Of The Palms, Florida",
      "(GWH)|(Greenwood)" => "Greenwood Hills"}.each do |(k,v)|
      if "#{msg} #{subj}".index /#{k}/
          return Place.find_or_create_by_name(v)
      end
    end
    nil
  end
  
  def convert_to_audio_message
    AudioMessage.create(
                        :title => msg || '(missing title)',
                        :subj => subj,
                        :groupmsg => groupmsg,
                        :publish => publish,
                        :language => converted_language,
                        :speaker => converted_speaker,
                        :place => converted_place,
                        :filename => filename,
                        :duration => converted_duration,
                        :filesize => filesize,
                        :event_date => converted_event_date,
                        :created_at => add_date,
                        :updated_at => change_date
                        )

  end

  def self.convert_records(records)
    count = 0
    records.each do |v|
      a = v.convert_to_audio_message
      puts "Converted #{v.id} into #{a.id} #{a.full_title}, #{a.speaker.full_name}, #{a.place ? a.place.name : nil}"
      count+=1
    end
    count
  end
  
  def self.convert_all
    count=0
    VfcRecord.find_each(:batch_size => 1000) do |v|
      a = v.convert_to_audio_message
      puts "Converted #{v.id} into #{a.id} #{a.full_title}, #{a.speaker.full_name}, #{a.place ? a.place.name : nil}"
      count+=1
    end
    count
  end
  
end
