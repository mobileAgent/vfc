class AudioMessage < ActiveRecord::Base

  has_one :motm
  belongs_to :speaker
  belongs_to :language
  belongs_to :place

  acts_as_taggable

  cattr_reader :per_page
  @@per_page = 50
  
  scope :active, where("publish = ?",true).includes(:speaker,:language,:place)

  define_index do
    where "publish = 1"
    indexes [title, subj],  :as => :full_title, :sortable => true
    indexes [speaker.last_name, speaker.first_name, speaker.middle_name],
       :as => :speaker_name, :sortable => true
    indexes place.name, :as => :place, :sortable => true
    indexes language.name, :as => :language, :sortable => true
    indexes event_date, :sortable => true

    has filesize, duration, place_id, language_id, speaker_id
  end

  def full_title
    if subj && subj.length > 0
      "#{title} ~ #{subj}"
    else
      title
    end
  end

  def autocomplete_title
    full_title.gsub(/[-,:;~!?&()]+/,' ').gsub(/[\"\']+/,'')
  end

  def year
    event_date.present? ? event_date.year : nil
  end
  
  # turn number of seconds into hh:mm:ss
  def human_duration
    if duration.present?
      "%02d:%02d:%02d" % [(duration/3600),((duration%3600)/60),(duration%60)]
    else
      nil
    end
  end      

  def human_filesize
    return "0" if (filesize.nil? || filesize == 0)
    return "#{filesize/1.kilobyte} kb" if filesize <= 1.megabytes
    "#{filesize/1.megabyte} mb"
  end
  
end
