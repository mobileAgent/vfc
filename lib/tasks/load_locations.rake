namespace :vfc do

  desc "load locations"
  task :load_locations => :environment do
    {"Turkey Hill" => "Turkey Hill Camp",
      "Storybook" => "Storybook Lodge",
      "Ramseur" => "Ramseur, North Carolina",
      "Wilmington" => "Wilmington, North Carolina",
      "Dallas" => "Dallas, Texas",
      "West Virginia" => "Terra Alta, West Virginia",
      "St.Louis" => "St. Louis, Missouri",
      "Omaha" => "Omaha, Nebraska",
      "Spanish Wells" => "Spanish Wells, Bahamas",
      "Hollywood Bible Ch" => "Hollywood, Florida",
      "Camp Horizon" => "Camp Horizon, Florida",
      "Camp Living Water" => "Camp Living Water",
      "Galilee Bible" => "Galilee Bible Camp",
      "Rockville" => "Rockville, Maryland",
      "Durham" => "Durham, North Carolina",
      "Raleigh" => "Raleigh, North Carolina",
      "Vancouver" => "Vancouver, BC",
      "Greenwood Hills" => "Greenwood Hills",
      "GWH" => "Greenwood Hills"}.each do |k,v|
      p = Place.find_by_name(v) || Place.create(:name => v)
      a = AudioMessage.active.all(:conditions => ["(msg like ? or subj like ? ) and place_id is null","%#{k}%","%#{k}%"])
      puts "Updating #{a.size} messages for #{k} => #{v} (#{p.id})"
      a.each { |msg| msg.update_attributes :place_id => p.id}
    end
  end
  
end
