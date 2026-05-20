class Language < ActiveRecord::Base
  has_many :audio_messages
  has_many :places, -> { distinct }, :through => :audio_messages
  has_many :speakers, -> { where("audio_messages.publish = true").order(:last_name, :first_name).distinct }, :through => :audio_messages
  
  scope :locale,  lambda {|loc| where("cc = ?", loc).limit(1) }
  scope :default, lambda { where("cc = ?", "en").limit(1) }
end
