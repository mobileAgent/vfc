class DatesController < ApplicationController

  def index
    @dates = AudioMessage.active
      .where("audio_messages.created_at > ?",1.year.ago)
      .group("date_format(audio_messages.created_at,'%Y-%m')")
      .order("audio_messages.created_at DESC")
      .count
    @speakers_by_date = {}
    @group_limit = 20
    @dates.keys.each do |date|
      @speakers_by_date[date] =
        AudioMessage.active
        .where("date_format(created_at,'%Y-%m') = ?", date)
        .limit(@group_limit)
        .order(:speaker_id)
        .group(:speaker_id)
    end
  end

  def speaker
    @date = params[:date]
    @speaker = Speaker.find(params[:speaker_id])
    @query_title = "Messages by #{@speaker.full_name} added on #{@date}"
    @items = AudioMessage.active
      .where("date_format(audio_messages.created_at,'%Y-%m') = ? and audio_messages.speaker_id = ?",@date,@speaker.id)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
    render :template => 'welcome/index'
  end

  def show
    @date = params[:id]
    @query_title = "Messages added on #{@date}"
    @items = AudioMessage.active
      .where("date_format(created_at,'%Y-%m') = ?",@date)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
    render :template => 'welcome/index'
  end
    
  
end
