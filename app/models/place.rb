class Place < ActiveRecord::Base
  
  has_many :audio_messages
  has_many :speakers, :through => :audio_messages, :uniq => true
  has_many :languages, :through => :audio_messages, :uniq => true
  
end
