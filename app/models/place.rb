class Place < ActiveRecord::Base
  
  has_many :audio_messages
  has_many :languages, :through => :audio_messages, :uniq => true
  has_many :speakers, :through => :audio_messages, :uniq => true,
           :conditions => {"audio_messages.publish" => true},
           :order => "last_name,first_name"
  
  def bio_html
    bio ? RDiscount.new(bio).to_html : nil
  end
  
end
