class DatesController < ApplicationController

  def index
    @dates = AudioMessage.active.count(:group => "date_format(add_date,'%Y-%m')", :order => "add_date DESC", :conditions => ["add_date > ?",1.year.ago])
    @speakers_by_date = {}
    @group_limit = 20
    @dates.keys.each do |date|
      @speakers_by_date[date] =
        AudioMessage.active.all(:group => :speaker_id,
                                :conditions => ["date_format(add_date,'%Y-%m') = ?",date],
                                :limit => @group_limit,
                                :order => :speaker_id)
    end
  end

  def speaker
    @date = params[:date]
    @speaker = Speaker.find(params[:speaker_id])
    @query_title = "Messages by #{@speaker.full_name} added on #{@date}"
    @items = AudioMessage.active.paginate(:page => params[:page], :conditions => ["date_format(add_date,'%Y-%m') = ? and speaker_id = ?",@date,params[:speaker_id]], :order => 'msg,subj')
    render :template => 'welcome/index'
  end

  def show
    @date = params[:id]
    @query_title = "Messages added on #{@date}"
    @items = AudioMessage.active.paginate(:page => params[:page], :conditions => ["date_format(add_date,'%Y-%m') = ?",@date], :order => 'speaker_id,msg,subj')
    render :template => 'welcome/index'
  end
    
  
end
