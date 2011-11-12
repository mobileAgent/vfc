class AudioMessagesController < ApplicationController

  def show
    @mp3 = AudioMessage.find(params[:id],:conditions => ['publish = ?',true])
    unless @mp3
      flash[:notice] = "No such record"
      redirect_to root_path
      return
    end
    file_path = AUDIO_PATH + @mp3.filename
    if File.exists?(file_path)
      if params[:dl]
        send_file file_path, :type => AUDIO_MIME_DL,
          :filename => @mp3.download_filename,
          :x_sendfile => (Rails.env == 'production')
      else
        render :text => url_for(:id => @mp3, :only_path => false, :dl => true),
               :content_type => AUDIO_MIME_PLAY
      end
    else
      logger.info "Missing file path for audio #{file_path}"
      flash[:warning] = "Sorry, that file is missing right now."
      redirect_to root_path
    end
  end

end
