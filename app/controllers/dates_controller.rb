class DatesController < ApplicationController
  
  
  # list by date preached
  def index
    @dates = AudioMessage.active
      .where("event_date is not null")
      .group("date_format(audio_messages.event_date,'%Y')")
      .order("audio_messages.event_date DESC")
      .count
  end

  # Lists by date added to vfc
  def years
    use_date = params[:dt] || "created_at"
    @age_limit = (params[:years] || "2").to_i.years.ago
    date_format = "'%Y-%m'"
    @dates = AudioMessage.active
      .where("audio_messages.#{use_date} > ?",@age_limit)
      .group("date_format(audio_messages.#{use_date},#{date_format})")
      .order("audio_messages.#{use_date} DESC")
      .count
    @speakers_by_date = {}
    @group_limit = 5
    @dates.keys.each do |date|
      @speakers_by_date[date] =
        AudioMessage.active
        .where("date_format(#{use_date},#{date_format}) = ?", date)
        .limit(@group_limit)
        .group(:speaker_id)
        .count
    end
  end
  
  # List speakers with counts for messages preached in a given year
  def year
    @year = params[:id].to_i
    @date_format = "'%Y'"
    @speaker_counts = AudioMessage.active
      .where("date_format(audio_messages.event_date,#{@date_format}) = ?", @year)
      .group(:speaker_id)
      .count
    @speaker_counts = @speaker_counts.sort { |a,b| b[1] <=> a[1] }
  end
  
  # list speakers of all messages added on a given yyyy-mm
  def speaker
    @date = params[:date]
    @speaker = Speaker.find(params[:speaker_id])
    @date_format = "'%Y-%m'"
    @query_title = "Messages by #{@speaker.full_name} added on #{@date}"
    @items = AudioMessage.active
      .where("date_format(audio_messages.created_at,#{@date_format}) = ? and audio_messages.speaker_id = ?",@date,@speaker.id)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
    render :template => 'welcome/index'
  end
  
  # list full details of all message added on yyyy-mm
  def show
    @date = params[:id]
    @date_format = "'%Y-%m'"
    @query_title = "Messages added on #{@date}"
    @items = AudioMessage.active
      .where("date_format(audio_messages.created_at,#{@date_format}) = ?",@date)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
    render :template => 'welcome/index'
  end
  
  # list full details of all messages preached by speaker in year
  def delivered
    @date = params[:id]
    @date_format = "'%Y'"
    @speaker = Speaker.find(params[:speaker_id])
    @query_title = "Messages delivered in #{@date} by #{@speaker.full_name}"
    @items = AudioMessage.active
      .where("date_format(audio_messages.event_date,#{@date_format}) = ?",@date)
      .where("speaker_id = ?",@speaker.id)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
    render :template => 'welcome/index'
  end
    
  
end
