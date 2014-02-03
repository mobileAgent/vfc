class Note < ActiveRecord::Base

  belongs_to :speaker
  has_many :audio_messages

  def filetype
    filename[filename.rindex(/\./)+1..-1]
  end
  
end
