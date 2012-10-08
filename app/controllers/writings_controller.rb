class WritingsController < ApplicationController

  def index
    @writings = Writing.all
  end

  def speaker
    @speaker = Speaker.find(params[:id])
    @writings = @speaker.writings
    render :index
  end

  def show
    begin
      @writing = Writing.find(params[:id])
      @speaker = @writing.speaker
    rescue
      flash[:notice] = t(:nsf)
      redirect_to writings_path and return
    end
    file_path = "#{WRITINGS_PATH}/#{@writing.filename}"
    if File.exists?(file_path)
      if (file_path.index(/\.pdf$/))
        mime_type = "application/pdf"
        xsendfile = (Rails.env == 'production')
        logger.debug "Sending file #{@writing.filename} using mime_type #{mime_type} and sendfile #{xsendfile}"
        send_file file_path, :type => mime_type, :disposition => 'inline', :x_sendfile => xsendfile
      elsif File.file?(file_path)
        @content = IO.read(file_path)
        @content.gsub!(/^.*<div id="(intro|content)"[^>]*>/m,'')
        @content.gsub!(/<\/div>\s+<div id="footer">.*/m,'')
        render :article
      else
        redirect_to :action => :speaker, :id => @writing.speaker.id
      end
    else
      flash[:notice] = t(:nsf)
      redirect_to :action => :speaker, :id => @writing.speaker.id
    end
    
  end
  
end
