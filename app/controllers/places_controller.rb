class PlacesController < ApplicationController

  before_filter :authorize_admin, :only => [:edit, :update, :new, :create]
  
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

  def new
    @place = Place.new
    render :edit
  end

  def create
    @place = Place.create(params[:place])
    flash[:notice] = "Created"
    redirect_to :action => :edit, :id => @place.id and return
  end

  def edit
    @place = Place.find(params[:id])
  end

  def update
    @place = Place.find(params[:id])
    if @place.update_attributes(params[:place])
      flash[:notice] = "Updated"
    end
    redirect_to :action => :edit, :id => @place.id and return
  end
  
end
