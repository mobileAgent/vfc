class VideosController < ApplicationController

  def index
    @require_video_player = true
    @videos = Video.all
  end

  def speaker
    @require_video_player = true
    @speaker = Speaker.find(params[:id])
    @videos = @speaker.videos
    render :index
  end

  def show
    begin
      @video = Video.find(params[:id])
      @speaker = @video.speaker
    rescue
      redirect_to videos_url, notice: t(:nsf) and return
    end
    
    file_path = "#{VIDEO_PATH}/#{@video.filename}"
    file_path.gsub!(/\.\./,'')
    if File.exists?(file_path)
      send_file file_path, :type => "video/mp4",
      :x_sendfile => (Rails.env == 'production')
    else
      redirect_to videos_url, notice: t(:nsf)
    end
  end

end
