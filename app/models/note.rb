class Note < ActiveRecord::Base

  belongs_to :speaker
  has_one :audio_message
  
end
