class SpeakersController < ApplicationController

  def index
    @speakers = Speaker.order('last_name,first_name')
    @message_counts = AudioMessage.active.group(:speaker_id).count
    @speakers.reject! { |s| @message_counts[s.id].nil? || @message_counts[s.id] == 0 }
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
    @speaker = Speaker.where("last_name = ?",params[:id]).first
    messages_by_speaker
  end

  def show
    @speaker = Speaker.find(params[:id])
    messages_by_speaker
  end

  private

  def messages_by_speaker
    @query_title ||= "Messages"
    @query_title << " by #{@speaker.full_name}"
    @conditions ||= {}
    @conditions[:speaker_id] = @speaker.id
    puts "Build title #{@query_title} and conditions #{@conditions}"
    @items = AudioMessage.search('',
                                 :with => @conditions,
                                 :order => "#{sort_column} #{sort_direction}",
                                 :match_mode => :boolean,
                                 :page => params[:page],
                                 :max_matches => 2500,
                                 :include => [:language, :speaker, :place])
    render :template => 'welcome/index'
  end

end
