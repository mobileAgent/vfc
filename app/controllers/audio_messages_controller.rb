class AudioMessagesController < ApplicationController

  before_filter :check_blocked_hosts
  before_filter :authorize_admin, :only => [:edit, :update, :delete]
  

  def show
    begin
      @mp3 = AudioMessage.find(params[:id],:conditions => ['publish = ?',true])
    rescue
      logger.debug "Request for non existent msg id #{params[:id]}"
    end
    unless @mp3
      flash[:notice] = t(:nsr)
      redirect_to root_path
      return
    end
    file_path = AUDIO_PATH + @mp3.filename
    if File.exists?(file_path)
      mime_type = params[:dl] ? AUDIO_MIME_DL : AUDIO_MIME_PLAY
      send_file file_path, :type => mime_type,
      :filename => @mp3.download_filename,
      :x_sendfile => (Rails.env == 'production')
    else
      logger.info "Missing file path for audio #{file_path}"
      flash[:warning] = t(:nsf)
      redirect_to root_path
    end
  end

  def delete
    @am = AudioMessage.find(params[:id])
    @am.delete
    flash[:notice] = "Deleted #{@am.speaker.catalog_name} #{@am.full_title} (#{@am.id})"
    redirect_to (request.referer || root_path)
  end

  def gold
    path = params[:speaker_name] + "/" + params[:filename] + ".mp3"
    @mp3 = AudioMessage.find(:first,
                             :conditions => ['publish = ? and filename = ?',
                                             true,path])
    if @mp3
      logger.debug "Looking for VFC-GOLD path #{path} found #{@mp3.id}"
      redirect_to :action => :show, :id => @mp3.id, :dl => true and return
    else
      logger.debug "Looking for VFC-GOLD path #{path} found nothing"
      flash[:notice] = t(:nsf)
      redirect_to root_path
    end
  end

  def edit
    @places = Place.order(:name)
    @speakers = Speaker.active.order(:first_name,:last_name)
    @languages = Language.order(:name)
    @audio_message = AudioMessage.find(params[:id])
  end

  def update
    @audio_message = AudioMessage.find(params[:id])
    if @audio_message.update_attributes(params[:audio_message])
      flash[:notice] = t(:updated)
    end
    redirect_to :action => :edit, :id => params[:id] and return
  end

  protected
  
  def check_blocked_hosts
    @blocked_hosts = Rails.cache.fetch("blocked_hosts",:expires_in => 30.minutes) {
      BlockedHost.all.inject([]) { |arr,bh| arr << bh.ip_address }
    }
    if @blocked_hosts.include?(request.remote_ip)
      logger.debug "Blocked host #{request.remote_ip} attempted mp3 access"
      redirect_to root_path
      return false
    end
    return true
  end

end
