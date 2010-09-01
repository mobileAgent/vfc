class PlacesController < ApplicationController

  def index
    @places = Place.all(:order => :name)
  end

  def show
    @place = Place.find(params[:id])
    @query_title = "Messages by location #{@place.name}"
    @items = AudioMessage.active.paginate(:page => params[:page],
                                          :conditions => ["place_id = ?",@place.id],
                                          :order => 'speaker_id,msg,subj',
                                          :include => [:language, :speaker, :place])
    render :template => 'welcome/index'
  end
  
end
