class WritingsController < ApplicationController

  def index
  end

  def get
    file_path = "#{WRITINGS_PATH}#{params[:name]}"
    file_path.gsub!(/\.\./,'')
    if File.exists?(file_path)
      if (file_path.index(/\.pdf$/))
        send_file file_path, :type => 'application/pdf',
           :x_sendfile => (Rails.env == 'production')
      else
        @content = IO.read(file_path)
        @content.gsub!(/^.*<div id="(intro|content)"[^>]*>/m,'')
        @content.gsub!(/<\/div>\s+<div id="footer">.*/m,'')
        render :article
      end
    else
      flash[:notice] = "That file is missing right now."
      redirect_to :action => :index
    end
    
  end
  
end
