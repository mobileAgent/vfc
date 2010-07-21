class Motm < ActiveRecord::Base
  belongs_to :audio_message
  named_scope :active, :conditions => ["updated_at >= ?",DateTime.now - 30], :order => :updated_at
end
