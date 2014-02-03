class DatesController < ApplicationController

  include DateHelper
  
  # list by date preached
  def index
    @dates = AudioMessage.active
      .where("event_date is not null")
      .group("date_format(audio_messages.event_date,'%Y')")
      .order("audio_messages.event_date DESC")
      .count
    # Peek at most recent load date
    @latest_addition_date = AudioMessage.maximum('created_at')
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
    @dates.keys.each do |date|
      @speakers_by_date[date] =
        generate_speaker_list_with_counts_for_date(date,date_format,use_date)
    end
    # Peek at most recent load date
    @latest_addition_date = AudioMessage.maximum('created_at')
  end
  
  # List speakers with counts for messages preached in a given year
  def year
    @year = params[:id].to_i
    date_format = "'%Y'"
    @speakers  = generate_speaker_list_with_counts_for_date(@year,date_format,"event_date")
  end
  
  # list speakers of all messages added on a given yyyy-mm
  def speaker
    @date = params[:date]
    @speaker = Speaker.find(params[:speaker_id])
    @date_format = "'%Y-%m'"
    @query_title = t(:query_by_speaker_and_date, :speaker => @speaker.full_name, :date => @date)
    @items = AudioMessage.active
      .where("date_format(audio_messages.created_at,#{@date_format}) = ? and audio_messages.speaker_id = ?",@date,@speaker.id)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
      .includes(:language, :speaker, :place, :tags)
    render :template => 'welcome/index'
  end
  
  # list full details of all message added on yyyy-mm
  def show
    @date = params[:id]
    @date_format = "'%Y-%m'"
    @query_title = t(:query_by_date, :date => @date)
    @items = AudioMessage.active
      .where("date_format(audio_messages.created_at,#{@date_format}) = ?",@date)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
      .includes(:language, :speaker, :place, :tags)
    
    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end
    
  end

  # list full details of all messages preached by speaker in year
  def delivered
    @date = params[:id]
    @date_format = "'%Y'"
    @speaker = Speaker.find(params[:speaker_id])
    @query_title = t(:query_by_speaker_and_year, :date => @date, :speaker => @speaker.full_name)
    @items = AudioMessage.active
      .where("date_format(audio_messages.event_date,#{@date_format}) = ?",@date)
      .where("audio_messages.speaker_id = ?",@speaker.id)
      .order(sort_column_ar + " " + sort_direction)
      .paginate(:page => params[:page], :per_page => AudioMessage.per_page)
      .includes(:language, :speaker, :place, :tags)
    
    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end
    
  end
    
  
end
