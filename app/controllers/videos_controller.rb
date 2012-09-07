class VideosController < ApplicationController

  def index
    @require_video_player = true
  end

  def file
    file_path = "#{AUDIO_PATH}/#{params[:name]}"
    file_path.gsub!(/\.\./,'')
    if File.exists?(file_path)
      send_file file_path, :type => "video/mp4",
      :x_sendfile => (Rails.env == 'production')
    else
      flash[:notice] = t(:nsf)
      redirect_to :action => :index
    end
  end

end
