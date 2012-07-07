class PlacesController < ApplicationController

  def index
    @places = Place.order(:name)
  end

  def speakers
    @place = Place.find(params[:id])
    @speakers = @place.speakers.order(:last_name, :first_name)
  end

  def show
    if params[:id].match(/([A-Z][A-Za-z]+)/)
      @place = Place.find(:first, :conditions => ["name like ?","#{params[:id]}%"])
    else
      @place = Place.find(params[:id])
    end
    @query_title = "Messages in #{@place.name}"
    @items = AudioMessage.search('',
                                 :with =>  { :place_id => @place.id },
                                 :order => sort_column,
                                 :match_mode => :boolean,
                                 :page => params[:page],
                                 :max_matches => 2500,
                                 :include => [:language, :speaker, :place])
    
    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end
    
  end
  
end
