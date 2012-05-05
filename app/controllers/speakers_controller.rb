class SpeakersController < ApplicationController

  include SpeakerHelper
  
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
    render :template => 'welcome/index'
  end

end
