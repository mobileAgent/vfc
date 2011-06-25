class AudioMessagesController < ApplicationController

  def tag_cloud
    @tags = AudioMessage.tag_counts
  end

  def show
    if (params[:id] == 'tag_cloud')
      tag_cloud and return
    end
    @mp3 = AudioMessage.find(params[:id])
    if File.exists?(@mp3.file_path)
      send_file @mp3.file_path, :type => 'audio/mp3', :x_sendfile => true
    else
      flash[:notice] = "Woah. That file has gone missing."
      redirect_to root_path
    end
  end
  

end
