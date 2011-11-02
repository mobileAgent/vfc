class AudioMessagesController < ApplicationController

  def show
    @mp3 = AudioMessage.find(params[:id],:conditions => ['publish = ?',true])
    unless @mp3
      flash[:notice] = "No such record"
      redirect_to root_path
      return
    end
    file_path = AUDIO_PATH + @mp3.filename
    mime_type = params[:dl] ? AUDIO_MIME_DL : AUDIO_MIME_PLAY
    if File.exists?(file_path)
      send_file file_path, :type => mime_type,
      :filename => @mp3.download_filename,
      :x_sendfile => true
    else
      logger.info "Missing file path for audio #{file_path}"
      flash[:notice] = "That file is missing right now but would be #{@mp3.download_filename}"
      redirect_to root_path
    end
  end

end
