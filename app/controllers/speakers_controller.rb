class SpeakersController < ApplicationController

  def index
    @speakers = Speaker.all(:order => 'last_name,first_name')
    @message_counts = AudioMessage.active.count(:group => :speaker_id)
  end

  def show
    @speaker = Speaker.find(params[:id])
    @query_title = "Messages by #{@speaker.full_name}"
    @items = AudioMessage.active.paginate(:page => params[:page],
                                            :conditions => ["speaker_id = ?",@speaker.id],
                                            :order => 'msg,subj')
    render :template => 'welcome/index'
  end

end
