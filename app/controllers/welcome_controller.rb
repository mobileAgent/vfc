class WelcomeController < ApplicationController
  
  include SpeakerHelper

  def index
    @tag_cloud = Rails.cache.fetch('tag_cloud', :expires_in => 10.minutes) {
      AudioMessage.tag_counts(:conditions => {:publish => true}, :order => :name)
    }
  end

  def contact
  end

  def about
  end

  def autocomplete
    @size_limit = 20
    @hits = []
    term = params[:term]
    t = "#{term}%"
    tt = "%#{term}%"
    # Get some tags
    if @hits.size < @size_limit
      @tags = Tag.where('name like ?',t)
        .limit(@size_limit - @hits.size)
        .order(:name)
      @hits += @tags.map { |t| t.name }
    end
    
    # Get some matching speaker names
    @speakers = Speaker.active
      .where("last_name like ? or first_name like ?",t,t)
      .limit(@size_limit-@hits.size)
      .order("last_name, first_name, middle_name")
    @hits += @speakers.map { |n| n.full_name }

    # Get some places
    if @hits.size < @size_limit
      @places = Place
        .where("name like ?",tt)
        .limit(@size_limit-@hits.size)
        .order(:name)
      @hits += @places.map { |n| n.name }
    end

    # Finally, get some audio messages
    if @hits.size < @size_limit
      begin
        @msgs = AudioMessage.search('',
                                    :conditions => {:full_title => term},
                                    :star => true,
                                    :max_matches => @size_limit-@hits.size)
        @hits += @msgs.map { |n| "#{n.autocomplete_title}, #{n.speaker.full_name}" }
      rescue ThinkingSphinx::SphinxError
      end
    end
    render :text => @hits.to_json and return
  end

  def search
    if request.xhr?
      autocomplete
      return
    end
    
    if params[:q].nil?
      redirect_to root_path
      return
    end
    
    @query_title = params[:q]
    
    @items = sphinx_search
    # this is weird, the error is on the ThinkingSphinx::Search
    # object but cannot just catch it by checking .error?
    # as that blows chunks
    begin
      if @items.nil? || @items.size == 0 ||
          (@items.respond_to?(:error?) && @items.error?)
        flash[:notice] = t(:no_match, :query => params[:q])
        redirect_to root_path and return
      end
    rescue
      puts "We had a problem with the results #{$!}"
      flash[:notice] = t(:no_match, :query => params[:q])
      redirect_to root_path and return
    end

    if @items.last.nil?
      flash[:notice] = t(:no_match, :query => params[:q])
      redirect_to root_path and return
    end
    
    if @items.last.speaker && @items.last.speaker.full_name == params[:q]
      @speaker = @items.last.speaker
      logger.debug "Setting speaker specific search with name match on query #{@speaker.full_name}"
    end

    if @items.last.place && @items.last.place.name == params[:q]
      @place = @items.last.place
    end
    
    if request.post? && params[:download] &&
        download_zipline(@items,params[:q],params[:page])
      return
    else
      respond_to do |format|
        format.html { render :action => :index }
        format.m3u  { render :action => :playlist, :layout => false }
      end
    end
  end

  def favicon
    redirect_to '/assets/vfc.ico'
  end

  private

  def sphinx_search
    logger.debug "Sphinx search for '#{params[:q]}' order #{sort_column}"
    AudioMessage.search(params[:q],
                        :page => params[:page],
                        :per_page => params[:per_page] || AudioMessage.per_page,
                        :order => sort_column,
                        :match_mode => :boolean,
                        :star => true,
                        :max_matches => 2500,
                        :include => [:language, :speaker, :place, :taggings])
  end

end


