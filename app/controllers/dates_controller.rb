class DatesController < ApplicationController

  def index
    @dates = AudioMessage.active.count(:group => "date_format(add_date,'%Y-%m')", :order => "add_date DESC")
    @speakers_by_date = {}
    @dates.keys.each do |date|
      @speakers_by_date[date] =
        AudioMessage.active.all(:group => :speaker_id,
                                :conditions => ["date_format(add_date,'%Y-%m') = ?",date],
                                :limit => 3,
                                :order => :speaker_id)
    end
  end
  
end
