class Motm < ActiveRecord::Base
  belongs_to :audio_message
  scope :active, :conditions => ["motms.updated_at >= ?",DateTime.now - 30],
                 :order => "motms.created_at desc",
                 :include => {:audio_message => [:language, :place, :speaker]}

  scope :language, lambda { |l| includes(:audio_message => [:speaker, :place, :language])
                               .where("audio_messages.language_id = ?",l.id)
                               .order("motms.created_at desc")}

  scope :not_language, lambda { |l| includes(:audio_message => [:speaker, :place, :language])
                               .where("audio_messages.language_id <> ?",l.id)
                               .order("motms.created_at desc")}
end
