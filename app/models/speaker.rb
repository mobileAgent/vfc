class Speaker < ActiveRecord::Base

  nilify_blanks  
  
  has_many :audio_messages
  has_many :videos
  has_many :writings
  has_many :notes, :through => :audio_messages, :uniq => true
  
  has_many :places, :through => :audio_messages, :uniq => true,
           :conditions => {"audio_messages.publish" => true},
           :order => :name

  has_many :languages, :through => :audio_messages, :uniq => true,
           :conditions => {"audio_messages.publish" => true},
           :order => :name
  
  scope :active, where("hidden = ?",false)

  attr_accessor :active_message_count, :active_speaker_count

  # this alias is for acts_as_taggable
  def count
    active_message_count || 0
  end
  
  # Fn M Ln
  def full_name
    s = ""
    s << "#{first_name} " unless first_name.blank?
    s << "#{middle_name} " unless middle_name.blank?
    s << last_name
    s << ", #{suffix}" unless suffix.blank?
    s
  end
  
  # Ln, Fn M
  def catalog_name
    s = ""
    s << last_name
    s << "," if (first_name || middle_name)
    s << " #{first_name}" if first_name
    s << " #{middle_name}" if middle_name
    s << " #{suffix}" unless suffix.blank?
    s
  end

  def audio_directory_name
    s = last_name
    s << "_#{first_name}" unless first_name.blank?
    s << "_#{middle_name}" unless middle_name.blank?
    s << "_#{suffix}" unless suffix.blank?
    s
  end

  # F Last
  def abbreviated_name
    s = ""
    s << "#{first_name[0]} " if first_name
    s << last_name
    s
  end
  
  # First letter of last name for indexing
  def index_letter
    last_name[0..0]
  end

  def bio_html
    bio ? RDiscount.new(bio).to_html : nil
  end

  def bio_snippet(length=80)
    bio ? "#{bio[0..length]}&hellip;".html_safe : ""
  end
  


end
