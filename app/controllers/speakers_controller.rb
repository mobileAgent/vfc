class SpeakersController < ApplicationController

  include SpeakerHelper
  before_filter :authorize_admin, :only => [:edit, :update, :new, :create]
  
  def index
    @speakers = Rails.cache.fetch('speaker_cloud',:expires_in => 30.minutes) {
      generate_speaker_list_with_counts
    }
    @letters = @speakers.collect(&:index_letter).sort.uniq
    if "cloud" == params[:view]
      @speaker_cloud = @speakers
      render :cloud and return
    end
  end

  def place
    @place = params[:place_id] ? Place.find(params[:place_id]) : nil
    @query_title = "Messages given in #{@place.name}"
    @conditions = {:place_id => @place.id}
    show
  end

  def language 
    @language = params[:language_id] ? Language.find(params[:language_id]) : nil
    @query_title = "Messages spoken in #{@language.name}"
    @conditions = {:language_id => @language.id}
    show
  end

  def name
  end

  def show
    if params[:id].match(/([A-Z][A-Za-z]+)/)
      @speaker = Speaker.where("concat(last_name,first_name,ifnull(middle_name,'')) = ?",$1).first
      # help emacs ruby mode get back in sync"
    else
      begin
        @speaker = Speaker.find(params[:id])
      rescue
        # No such speaker
      end
    end
    
    unless @speaker
      flash[:notice] = "Speaker not matched"
      redirect_to :action => :index and return
    end
    messages_by_speaker
  end

  def new
    @speaker = Speaker.new
    render :edit
  end

  def edit
    @speaker = Speaker.find(params[:id])
  end

  def create
    @speaker = Speaker.create(params[:speaker])
    Rails.cache.delete('speaker_cloud')
    flash[:notice] = "Created"
    redirect_to :action => :edit, :id => @speaker.id and return
  end

  def update
    @speaker = Speaker.find(params[:id])
    if @speaker.update_attributes(params[:speaker])
      Rails.cache.delete('speaker_cloud')
      flash[:notice] = "Updated"
    end
    redirect_to :action => :edit, :id => @speaker.id and return
  end

  private

  def messages_by_speaker
    @query_title ||= "Messages"
    @query_title << " by #{@speaker.full_name}"
    @conditions ||= {}
    @conditions[:speaker_id] = @speaker.id
    @items = AudioMessage.search('',
                                 :with => @conditions,
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
