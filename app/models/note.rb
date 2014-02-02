class Note < ActiveRecord::Base

  belongs_to :speaker
  has_one :audio_message

  def filetype
    filename[filename.rindex(/\./)+1..-1]
  end
  
end
