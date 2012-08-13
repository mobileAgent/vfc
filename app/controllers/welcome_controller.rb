class WelcomeController < ApplicationController
  
  include SpeakerHelper

  def index
    @motm = Rails.cache.fetch('motm',:expires_in => 30.minutes) {
      Motm.active.last
    }
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
      @msgs = AudioMessage.search('',
                                  :conditions => {:full_title => term},
                                  :star => true,
                                  :max_matches => @size_limit-@hits.size)
      @hits += @msgs.map { |n| "#{n.autocomplete_title}, #{n.speaker.full_name}" }
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
    if @items.size > 0 && @items.last.speaker.full_name == params[:q]
      @speaker = @items.last.speaker
    end
    
    if @items.size == 0
      flash[:notice] = t(:no_match, :query => params[:q])
      redirect_to root_path and return
    end
    
    if request.post? && params[:download] && download_zipline(@items,params[:q],params[:page])
      return
    else
      respond_to do |format|
        format.html { render :action => :index }
        format.m3u  { render :action => :playlist, :layout => false }
      end
    end
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


