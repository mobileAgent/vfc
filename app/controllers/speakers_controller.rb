class SpeakersController < ApplicationController

  include SpeakerHelper
  
  def index
    @speakers = Rails.cache.fetch('speaker_cloud_v2',:expires_in => 30.minutes) {
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
    @query_title = "Messages given at #{@place.name}"
    @conditions = {:place_id => @place.id}
    show
  end

  def language 
    @language = params[:language_id] ? Language.find(params[:language_id]) : nil
    @query_title = "Messages spoken in #{@language.name}"
    @conditions = {:language_id => @language.id}
    show
  end

  def show
    @speaker = current_resource
    unless @speaker
      redirect_to place_url, notice: t(:nsr) and return
    end
    messages_by_speaker
  end

  def new
    @speaker = Speaker.new
    render :edit
  end

  def edit
    @speaker = current_resource
  end

  def create
    @speaker = Speaker.create(params[:speaker])
    Rails.cache.delete('speaker_cloud')
    redirect_to edit_speaker_url(@speaker), notice: t(:created) and return
  end

  def update
    @speaker = current_resource
    if @speaker.update_attributes(params[:speaker])
      Rails.cache.delete('speaker_cloud')
      flash[:notice] = t(:updated)
    end
    redirect_to edit_speaker_url(@speaker) and return
  end

  private

  def messages_by_speaker
    @query_title ||= t(:messages)
    @query_title << " " + t(:attribution, :speaker => @speaker.full_name)
    @conditions ||= {}
    @conditions[:speaker_id] = @speaker.id
    @items = AudioMessage.search('',
                                 :with => @conditions,
                                 :order => sort_column,
                                 :match_mode => :boolean,
                                 :page => params[:page],
                                 :max_matches => 5000,
                                 :include => [:language, :speaker, :place, :tags])
    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end
  end

  def current_resource
    if params[:id]
      if params[:id].match(/([A-Z][A-Za-z]+)/)
        @current_resource ||= Speaker.where("concat(last_name,first_name,ifnull(middle_name,'')) = ?",$1).first
        # help emacs ruby mode get back in sync"
      else
        begin
          @current_resource ||= Speaker.find(params[:id])
        rescue
          # No such speaker
        end
      end
    end
  end
  
end
