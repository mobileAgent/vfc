class Note < ApplicationRecord

  belongs_to :speaker
  has_many :audio_messages

  def filetype
    filename[filename.rindex(/\./)+1..-1]
  end
  
end
