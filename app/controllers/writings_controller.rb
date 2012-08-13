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
      elsif File.file?(file_path)
        @content = IO.read(file_path)
        @content.gsub!(/^.*<div id="(intro|content)"[^>]*>/m,'')
        @content.gsub!(/<\/div>\s+<div id="footer">.*/m,'')
        render :article
      else
        redirect_to :action => :index
      end
    else
      flash[:notice] = t(:nsf)
      redirect_to :action => :index
    end
    
  end
  
end
