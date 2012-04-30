class AudioMessagesController < ApplicationController

  before_filter :check_blocked_hosts

  def show
    @mp3 = AudioMessage.find(params[:id],:conditions => ['publish = ?',true])
    unless @mp3
      flash[:notice] = "No such record"
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
      flash[:warning] = "Sorry, that file is missing right now."
      redirect_to root_path
    end
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
      render :text => "Nothing found for #{path}", :status => 404
    end
  end

  protected
  
  def check_blocked_hosts
    @blocked_hosts = Rails.cache.fetch("blocked_hosts",:expires_in => 30.minutes) {
      BlockedHost.all.inject([]) { |arr,bh| arr << bh.ip_address }
    }
    if @blocked_hosts.include?(request.remote_ip)
      logger.debug "Blocked host #{request.remote_ip} attempted mp3 access"
      redirect_to root_path
    end
  end

end
