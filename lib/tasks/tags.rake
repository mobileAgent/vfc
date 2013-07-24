namespace :tags do
  
  desc "create tags from titles"
  task :autotag => :environment do

    starting_id = (ENV['starting_id'] || "1").to_i
    %w(Missions Salvation Easter Christmas Passover Tabernacle Joshua Noah Abraham Joseph Grace Israel Creation Prophecy Crucifixion Resurrection Elijah Elisha Solomon David Love Jacob Esau Isaac Prayer Jesus Christ Messiah Parables Jonah Judas Satan Josiah Hezekiah Gideon Miracles Golgotha Gethsemane Moses CMML Genesis Exodus Leviticus Numbers Deuteronomy Judges Ruth Esther Ezra Nehemiah Job Psalm Proverbs Ecclesiastes Jeremiah Isaiah Lamentations Ezekiel Hosea Joel Amos Obadiah Micah Nahum Habakkuk Zephaniah Haggai Zecharaiah Malachi Matthew Mark Luke Acts Romans Galatians Ephesians Philippians Colossians Titus Philemon Hebrews James Jude Revelation Mother Wife Children Women Repentance Heaven Hell Daniel Rahab Samson Noah).each do |label|
      AudioMessage.search('',
                          :conditions => {:full_title => label},
                          :match_mode => :extended,
                          :max_matches => 2500,
                          :per_page => 2500,
                          :include => :taggings).each do |item|
        next if item.id < starting_id
        unless item.tag_list.include?(label)
          item.tag_list << label
          item.save
        end
      end
    end

    # Sphinx isn't good for these, use regexp
    ["1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "1 Corinthians", "2 Corinthians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "1 Peter", "2 Peter", "1 John", "2 John", "3 John"].each do |label|
      slabel = label.gsub(/ /,'')
      AudioMessage.find(:all, :conditions => ["(title rlike(?) or subj rlike(?)) and id >= ?",label,label,starting_id]).each do |item|
        unless item.tag_list.include?(slabel)
          item.tag_list << slabel
          item.save
        end
      end
    end

    # These need defeats
    label = 'John'
    AudioMessage.search('',
                        :conditions => {:full_title => "John" },
                        :match_mode => :extended,
                        :star => true,
                        :max_matches => 2500,
                        :per_page => 2500,
                        :include => :taggings).each do |item|
      next if item.id < starting_id
      unless item.tag_list.join(',').index(/John/)
        item.tag_list << label
        item.save
      end
    end
    
  end
end
