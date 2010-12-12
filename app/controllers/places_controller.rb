class PlacesController < ApplicationController

  def index
    @places = Place.order(:name)
  end

  def speakers
    @place = Place.find(params[:id])
    @speakers = @place.speakers.order(:last_name, :first_name)
  end

  def show
    @place = Place.find(params[:id])
    @query_title = "Messages in #{@place.name}"
    @items = AudioMessage.search('',
                                 :with =>  { :place_id => @place.id },
                                 :order => "#{sort_column} #{sort_direction}",
                                 :match_mode => :boolean,
                                 :page => params[:page],
                                 :max_matches => 2500,
                                 :include => [:language, :speaker, :place])
    render :template => 'welcome/index'
  end
  
end
