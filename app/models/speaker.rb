class Speaker < ActiveRecord::Base
  
  has_many :audio_messages
  has_many :places, :through => :audio_messages, :uniq => true,
    :order => :name
  
  # Fn M Ln
  def full_name
    s = ""
    s << "#{first_name} " if first_name
    s << "#{middle_name} " if middle_name
    s << last_name
    s
  end
  
  # Ln, Fn M
  def catalog_name
    s = ""
    s << last_name
    s << ", #{first_name}" if first_name
    s << " #{middle_name}" if middle_name
    s
  end
  
  # First letter of last name for indexing
  def index_letter
    last_name[0..0]
  end
  
end
