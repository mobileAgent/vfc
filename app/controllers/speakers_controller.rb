class SpeakersController < ApplicationController

  def index
    @speakers = Speaker.all(:order => 'last_name,first_name')
    @message_counts = AudioMessage.active.count(:group => :speaker_id)
    @speakers.reject! { |s| @message_counts[s.id].nil? || @message_counts[s.id] == 0 }
  end

  def show
    @speaker = Speaker.find(params[:id])
    @query_title = "Messages by #{@speaker.full_name}"
    @items = AudioMessage.active.paginate(:page => params[:page],
                                            :conditions => ["speaker_id = ?",@speaker.id],
                                          :order => 'msg,subj',
                                          :include => [:language, :speaker, :place])
    render :template => 'welcome/index'
  end

end
