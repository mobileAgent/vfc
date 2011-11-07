class HymnsController < ApplicationController

  def index
  end

  def show
    h = Hymn.all[params[:id].to_i]
    if h
      file_path = AUDIO_PATH + h.file
      if File.exists?(file_path)
        send_file file_path, :type => AUDIO_MIME_DL,
           :x_sendfile => (Rails.env == 'production') and return
      end
    end
    
    logger.info "Missing file for hymn #{params[:id]}"
    flash[:warning] = "Sorry, that file is missing right now."
    redirect_to :action => :index
  end
  
end
