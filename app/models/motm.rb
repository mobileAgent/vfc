class Motm < ActiveRecord::Base
  belongs_to :audio_message
  named_scope :active, :conditions => ["motms.updated_at >= ?",DateTime.now - 30], :order => :updated_at, :include => [:audio_message, {:audio_message => :speaker}]
end
