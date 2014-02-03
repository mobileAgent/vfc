class NotesController < ApplicationController

  def index
    @notes = Note.all
  end

  def speaker
    @speaker = Speaker.find(params[:id])
    @notes = Note.find(:all, :conditions => ['speaker_id = ?',@speaker.id], :include => [:audio_messages], :order => :title)
    render :index
  end

  def audio
    @speaker = Speaker.find(params[:id])
    @current_resource = @speaker
    if params[:note_id]
      range = params[:note_id].to_i
      @note = Note.find(params[:note_id].to_i)
      @query_title = "Message for Note - #{@note.title}"
    else
      range = 1..2**32-1 # sphinx doesn't do "greather than" on attributes
      @query_title = "Messages with Notes by #{@speaker.full_name}"
    end
    @items = AudioMessage.search('',
                                 :with => {:speaker_id => @speaker.id, :note_id => range },
                                 :order => sort_column,
                                 :match_mode => :boolean,
                                 :page => params[:page],
                                 :max_matches => 2500,
                                 :include => [:language, :speaker, :place, :tags, :notes])

    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end
  end
  
  def show
    begin
      @note = Note.find(params[:id])
      @speaker = @note.speaker
    rescue
      redirect_to root_url, notice: t(:nsf) and return
    end
    file_path = "#{NOTES_PATH}/#{@note.filename}"
    if File.exists?(file_path)
      if (file_path.index(/\.pdf$/))
        mime_type = "application/pdf"
        xsendfile = (Rails.env == 'production')
        logger.debug "Sending file #{@note.filename} using mime_type #{mime_type} and sendfile #{xsendfile}"
        send_file file_path, :type => mime_type, :disposition => 'inline', :x_sendfile => xsendfile
      elsif File.file?(file_path)
        @content = IO.read(file_path)
        @content.gsub!(/^.*<div id="(intro|content)"[^>]*>/m,'')
        @content.gsub!(/<\/div>\s+<div id="footer">.*/m,'')
        render 'writings/article'
      else
        redirect_to :action => :speaker, :id => @note.speaker.id
      end
    else
      flash[:notice] = t(:nsf)
      redirect_to :action => :speaker, :id => @note.speaker.id
    end
    
  end
  
end
