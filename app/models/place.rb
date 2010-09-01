class Place < ActiveRecord::Base
  
  has_many :audio_messages
  has_many :languages, :through => :audio_messages, :uniq => true
  has_many :speakers, :through => :audio_messages, :uniq => true,
           :order => "last_name,first_name"
  
end
