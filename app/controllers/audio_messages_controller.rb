class AudioMessagesController < ApplicationController

  before_filter :check_blocked_hosts
  # before_filter :authorize_admin, :only => [:edit, :update, :delete]
  

  def show
    unless current_resource
      redirect_to root_url, notice: t(:nsr)
      return
    end
    file_path = AUDIO_PATH + current_resource.filename
    if File.exists?(file_path)
      mime_type = params[:dl] ? AUDIO_MIME_DL : AUDIO_MIME_PLAY
      send_file file_path, :type => mime_type,
      :filename => current_resource.download_filename,
      :x_sendfile => (Rails.env == 'production')
    else
      logger.info "Missing file path for audio #{file_path}"
      redirect_to root_url, warning: t(:nsf)
    end
  end

  def delete
    @am = current_resource
    @am.update_attributes(:publish => false)
    redirect_to (request.env["HTTP_X_XHR_REFERER"] || request.env["HTTP_REFERER"] || root_url),
          notice: "Deleted #{@am.speaker.catalog_name} #{@am.full_title} (#{@am.id})"
  end

  def gold
    @mp3 = current_resource
    if @mp3
      redirect_to audio_message_url(@mp3,:dl => true) and return
    else
      redirect_to root_url, notice: t(:nsf)
    end
  end

  def edit
    @places = Place.order(:name)
    @speakers = Speaker.active.order(:last_name,:first_name)
    @languages = Language.order(:name)
    @audio_message = current_resource
  end

  def update
    @audio_message = current_resource
    referer = params[:referer][:url]
    if @audio_message.update_attributes(params[:audio_message])
      flash[:notice] = t(:updated)
    end
    if referer
      redirect_to referer and return
    else
      redirect_to edit_audio_message_url(@audio_message) and return
    end
  end

  protected
  
  def check_blocked_hosts
    @blocked_hosts = Rails.cache.fetch("blocked_hosts",:expires_in => 30.minutes) {
      BlockedHost.all.inject([]) { |arr,bh| arr << bh.ip_address }
    }
    if @blocked_hosts.include?(request.remote_ip)
      logger.debug "Blocked host #{request.remote_ip} attempted mp3 access"
      redirect_to root_url
      return false
    end
    return true
  end

  def current_resource
    begin
      if params[:action] == "gold"
        path = params[:speaker_name] + "/" + params[:filename] + ".mp3"
        @current_resource = AudioMessage.find(:first,
                                              :conditions => ['publish = ? and filename = ?',
                                                              true,path])
      elsif params[:id]
        @current_resource ||= AudioMessage.find(params[:id],:conditions => ['publish = ?',true])
      end
    rescue
    end
  end

end
