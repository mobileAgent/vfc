class NotesController < ApplicationController

  def index
    @notes = Note.all
  end

  def speaker
    @speaker = Speaker.find(params[:id])
    @notes = @speaker.notes
    @notes.sort! { |a,b| a.title <=> b.title }
    render :index
  end

  def audio
    @speaker = Speaker.find(params[:id])
    @current_resource = @speaker
    @query_title = "Messages with Notes by #{@speaker.full_name}"
    @items = AudioMessage.find(:all, :conditions => ['speaker_id = ? and note_id is not null and publish = ?',@speaker.id,true],
                               :order => [:title,:subj], :include => [:speaker, :place, :tags, :note])

    meta = class << @items; self; end
    meta.send(:define_method, :total_pages) do
      1
    end
    meta.send(:define_method, :total_entries) do
      size
    end

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
