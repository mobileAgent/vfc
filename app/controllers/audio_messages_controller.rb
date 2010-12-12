class AudioMessagesController < ApplicationController

  def show
    @mp3 = AudioMessage.find(params[:id])
    if File.exists?(@mp3.file_path)
      send_file @mp3.file_path, :type => 'audio/mp3', :x_sendfile => true
    else
      flash[:notice] = "Woah. That file has gone missing."
      redirect_to root_path
    end
  end
  

end
