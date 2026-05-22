class Place < ActiveRecord::Base

  nilify_blanks  
  
  has_many :audio_messages
  has_many :languages, -> { distinct }, :through => :audio_messages
  has_many :speakers, -> { where("audio_messages.publish = true").order(:last_name, :first_name).distinct }, :through => :audio_messages

  attr_accessor :active_message_count, :active_speaker_count
  
  def bio_html
    bio ? RDiscount.new(bio).to_html : nil
  end

  def bio_snippet(length=80)
    bio ? "#{bio.gsub(/\*/,'')[0..length]}&hellip;".html_safe : ""
  end

  def table_name
    if name.length > 10 && name.index(/,/)
      name.gsub(/,.*/,'')
    else
      name
    end
  end
  
end
