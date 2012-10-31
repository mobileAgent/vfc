class HymnsController < ApplicationController

  def index
    @hymns = Hymn.order(:title)
  end

  def show
    h = Hymn.find(params[:id])
    if h
      file_path = AUDIO_PATH + h.filename
      if File.exists?(file_path)
        send_file file_path, :type => AUDIO_MIME_DL,
           :x_sendfile => (Rails.env == 'production') and return
      end
    end
    
    logger.info "Missing file for hymn #{params[:id]}"
    redirect_to hymns_path, notice: t(:nsf)
  end
  
end
