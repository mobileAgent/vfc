class Speaker < ActiveRecord::Base
  
  has_many :audio_messages

  def full_name
    s = ""
    s << "#{first_name} " if first_name
    s << "#{middle_name} " if middle_name
    s << last_name
    s
  end

  def catalog_name
    s = ""
    s << last_name
    s << ", #{first_name}" if first_name
    s << " #{middle_name}" if middle_name
    s
  end
  
end
