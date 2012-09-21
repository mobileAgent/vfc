class Language < ActiveRecord::Base
  has_many :audio_messages
  has_many :places, :through => :audio_messages, :uniq => true
  has_many :speakers, :through => :audio_messages, :uniq => true,
           :conditions => {"audio_messages.publish" => true},
           :order => "last_name,first_name"
  
  scope :locale, lambda {|loc| where("cc = ?",loc).limit(1)}
  scope :default, where("cc = ?","en").limit(1)
end
