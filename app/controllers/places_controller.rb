class PlacesController < ApplicationController

  def index
    @places = AudioMessage.active.count(:group => :place, :order => :place, :conditions => ["place is not null"])
    @speakers_by_place = {}
    @places.keys.each do |place|
      @speakers_by_place[place] =
        AudioMessage.active.all(:group => :speaker_id,
                                :conditions => ["place = ?",place],
                                :limit => 5,
                                :order => :add_date)
    end
  end
  
end
