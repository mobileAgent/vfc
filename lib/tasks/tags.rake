namespace :tags do
  
  desc "create tags from titles"
  task :autotag => :environment do
    %w(Missions Conference Salvation Easter Christmas Passover Tabernacle).each do |label|
      AudioMessage.find(:all, :conditions => ["title like ?","%#{label}%"]).each do |item|
        item.tag_list << tag.downcase
        item.save
      end
    end
  end
end
