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

  # Turn those conditions into a google style advanced search string
  # and redirect to the normal search so users can learn how
  def advanced_search
    @query = AdvancedSearch.to_query_string(params)
    redirect_to :action => :search, :q => @query and return
  end

  # Run a search!
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

  def player
    @audio_message = AudioMessage.active.find(params[:id])
    @time_offset = (params[:time_offset] || "0").to_i
    @media_url = url_for(:controller => :audio_messages, :action => :show, :id => @audio_message, :only_path => false)
    @player_title = @audio_message.player_title.titleize
    logger.debug "Popout with #{@player_title} #{@media_url} and offset #{@time_offset}"
    render :layout => "popout"
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

  def run_sphinx_search(query,star=true,match_mode=:boolean,redirect_url=root_url)

    items = sphinx_search(query,star,match_mode)
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

  def sphinx_search(query,star=true,match_mode=:boolean)
    logger.debug "Sphinx search for '#{params[:q]}' order #{sort_column}"
    if AdvancedSearch.is_advanced?(query)
      conditions = AdvancedSearch.to_conditions(query)
      query=conditions.delete(:query)
    end
    options = {
      :page => params[:page],
      :per_page => params[:per_page] || AudioMessage.per_page,
      :order => sort_column,
      :match_mode => match_mode,
      :star => star,
      :max_matches => 5000,
      :include => [:language, :speaker, :place, :tags ]
    }
    options[:conditions] = conditions if conditions
    AudioMessage.search(query,options)
  end

end


