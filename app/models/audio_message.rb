class AudioMessage < ActiveRecord::Base
  set_table_name 'vfc'
  
  has_one :motm
  belongs_to :speaker
  belongs_to :language
  
  named_scope :active, :conditions => ["download = ? and publish = ?",true,true]

  define_index do
    where "download = 1 and publish = 1"
    indexes msg, :sortable => true 
    indexes subj, :sortable => true
    indexes speaker.last_name, :as => :speaker_last_name, :sortable => true, :facet => true
    indexes speaker.first_name, :as => :speaker_first_name, :sortable => true
    indexes place, :sortable => true, :facet => true
    indexes language.name, :as => :language, :sortable => true, :facet => true
    indexes date, :sortable => true

    where "download = 1 and publish = 1"
  end

  def title
    if subj && subj.length > 0
      "#{msg}  ~ #{subj}"
    else
      msg
    end
  end

  def year
    if date.present?
      if date == "--/--/--"
        ""
      elsif date.index /--([0-9]{4})--/
        date.gsub /--([0-9]{4})--/,'\1'
      elsif date =~ /^[0-9]{4}$/
        date
      elsif date.index /[-0-9]{2}\/[-0-9]{2}\/([0-9]{2})/
        yy = date.gsub /[-0-9]{2}\/[-0-9]{2}\/([0-9]{2})/,'\1'
        century = Time.now.year / 100
        yy.to_i < 50 ? "#{century}#{yy}" : "#{century - 1}#{yy}"
      else
        date
      end
    else
      ""
    end
  end
  
end
