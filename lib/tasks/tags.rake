namespace :tags do
  
  desc "create tags from titles"
  task :autotag => :environment do
    %w(Missions Conference Salvation Easter Christmas Passover Tabernacle Joshua Noah Abraham Joseph Grace Israel Creation Prophecy Crucifixion Resurrection Elijah Elisha Solomon David Love Jacob Esau Isaac Prayer Jesus Christ Messiah Parables Jonah Judas Satan Josiah Hezekiah Gideon Miracles Golgotha Gethsemane Moses ).each do |label|
      AudioMessage.find(:all, :conditions => ["title like ?","%#{label}%"]).each do |item|
        tag = label.downcase
        unless item.tag_list.include?(tag)
          item.tag_list << tag
          item.save
        end
      end
    end
  end
end
