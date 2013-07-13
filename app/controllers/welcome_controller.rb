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

  # Deliver the advanced search page
  def advanced
  end

  # Run the advanced search
  def advanced_search
    star_mode = "true" != params[:exact_match]
    sphinx_mode = :boolean
    
    conditions = {
      :full_title => params[:title],
      :speaker_name => params[:speaker],
      :tags => params[:tags],
      :event_date => params[:event_date],
      :place => params[:place],
      :language => params[:language] 
    }

    # remove blank items
    conditions.delete_if { |k,v| v.blank? }
    
    @query_title = t "menu.advanced_search"
    
    @items = run_sphinx_search('',star_mode,sphinx_mode,conditions,'/welcome/advanced')
    if @items
      render_search_results(@items) and return
    end
  end

  def search
    if request.xhr?
      autocomplete
      return
    end
    
    if params[:q].nil?
      redirect_to(root_url) and return
    end
    
    @query_title = params[:q]
    
    @items = run_sphinx_search(params[:q])
    
    if @items
      render_search_results(@items) and return
    end
  end

  def favicon
    redirect_to '/assets/vfc.ico'
  end

  def thanks
  end

  private

  def render_search_results(items)
    
    if request.post? && params[:download] &&
        download_zipline(items,params[:q],params[:page])
      return
    end

    if @items.last.speaker && @items.last.speaker.full_name == params[:q]
      @speaker = @items.last.speaker
      logger.debug "Setting speaker specific search with name match on query #{@speaker.full_name}"
    end

    if @items.last.place && @items.last.place.name == params[:q]
      @place = @items.last.place
    end

    respond_to do |format|
      format.html { render :action => :index }
      format.m3u  { render :action => :playlist, :layout => false }
    end
  end

  def run_sphinx_search(query,star=true,match_mode=:boolean,conditions=nil,redirect_url=root_url)

    items = sphinx_search(query,star,match_mode,conditions)
    msg = query.blank? ? t("menu.advanced_search") : query
    
    # this is weird, the error is on the ThinkingSphinx::Search
    # object but cannot just catch it by checking .error?
    # as that blows chunks
    begin
      if items.nil? || items.size == 0 ||
          (items.respond_to?(:error?) && items.error?)
        items = nil
        redirect_to redirect_url, notice: t(:no_match, :query => msg) and return
      end
    rescue
      puts "We had a problem with the results #{$!}"
      items = nil
      redirect_to redirect_url, notice: t(:no_match, :query => msg) and return
    end

    if items.last.nil?
      items = nil
      redirect_to redirect_url, notice: t(:no_match, :query => msg) and return
    end

    items
  end

  def sphinx_search(query,star=true,match_mode=:boolean,conditions)
    logger.debug "Sphinx search for '#{params[:q]}' order #{sort_column}"
    options = {
      :page => params[:page],
      :per_page => params[:per_page] || AudioMessage.per_page,
      :order => sort_column,
      :match_mode => match_mode,
      :star => star,
      :max_matches => 2500,
      :include => [:language, :speaker, :place, :taggings]
    }
    options[:conditions] = conditions if conditions
    AudioMessage.search(query,options)
  end

end


