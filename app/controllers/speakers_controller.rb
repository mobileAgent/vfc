class SpeakersController < ApplicationController

  def index
    @speakers = Speaker.all(:order => 'last_name,first_name')
    @message_counts = AudioMessage.active.count(:group => :speaker_id)
    @speakers.reject! { |s| @message_counts[s.id].nil? || @message_counts[s.id] == 0 }
  end

  def show
    @speaker = Speaker.find(params[:id])
    @place = params[:place_id] ? Place.find(params[:place_id]) : nil
    @query_title = "Messages by #{@speaker.full_name}"
    @query_title << " in #{@place.name}" if @place
    @conditions = ["speaker_id = ?"]
    @conditions[0] << " and place_id = ?" if @place
    @conditions << @speaker.id
    @conditions << @place.id if @place
    @items = AudioMessage.active.paginate(:page => params[:page],
                                          :conditions => @conditions,
                                          :order => 'msg,subj',
                                          :include => [:language, :speaker, :place])
    render :template => 'welcome/index'
  end

end
