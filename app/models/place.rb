class Place < ActiveRecord::Base

  nilify_blanks  
  
  has_many :audio_messages
  has_many :languages, :through => :audio_messages, :uniq => true
  has_many :speakers, :through => :audio_messages, :uniq => true,
           :conditions => {"audio_messages.publish" => true},
           :order => "last_name,first_name"

  attr_accessor :active_message_count, :active_speaker_count
  
  def bio_html
    bio ? RDiscount.new(bio).to_html : nil
  end

  def bio_snippet(length=80)
    bio ? "#{bio.gsub(/\*/,'')[0..length]}&hellip;".html_safe : ""
  end
  
end
