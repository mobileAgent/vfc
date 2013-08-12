class PlacesController < ApplicationController

  include PlaceHelper

  def index
    @places = generate_place_list_with_counts
    
  end

  def speakers
    @place = current_resource
    if @place.nil?
      flash[:notice] = t("nsr")
      redirect_to root_url and return
    end
    @speakers = generate_place_speaker_list_with_counts(@place)
  end

  def show
    @place = current_resource
    if @place.nil?
      redirect_to root_url, notice: t(:nsr) and return
    end

    @query_title = "Messages in #{@place.name}"
    @items = AudioMessage.search('',
                                 :with =>  { :place_id => @place.id },
                                 :order => sort_column,
                                 :match_mode => :boolean,
                                 :page => params[:page],
                                 :max_matches => 2500,
                                 :include => [:language, :speaker, :place, :tags])
    
    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end
    
  end

  def new
    @place = Place.new
    render :edit
  end

  def create
    @place = Place.create(params[:place])
    redirect_to edit_place_url(@place), notice: "Created" and return
  end

  def edit
    @place = current_resource
  end

  def update
    @place = current_resource
    if @place.update_attributes(params[:place])
      flash[:notice] = t(:updated)
    end
    redirect_to edit_place_url(@place) and return
  end

  protected
  
  def current_resource
    if params[:id]
      begin
        if params[:id].match(/([A-Z][A-Za-z]+)/)
          @current_resource ||= Place.find(:first, :conditions => ["name like ?","#{params[:id]}%"])
        else
          @current_resource ||= Place.find(params[:id])
        end
      rescue
      end
    end
  end

  
end
