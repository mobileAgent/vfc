class LanguagesController < ApplicationController

  def index
    # .to_a materializes the relation so the Array operations below
    # (delete, prepend, reject!) work. On a relation, .delete would
    # hit the database and .prepend doesn't exist.
    @languages = Language.order(:name).to_a
    @languages.each do |lang|
      if lang.cc == @locale
        # move it to the top of the list
        logger.debug "moving #{lang} to top for #{@locale}"
        @languages.prepend(@languages.delete(lang))
        break
      else
        logger.debug "no change for #{lang.cc} in #{@locale} #{lang.cc == @locale}"
      end
    end
    @language_counts = AudioMessage.active.group(:language_id).count
    @languages.reject! {|l| @language_counts[l.id].nil? }
    @speakers_counts = {}
    @limit = params[:limit] || 10
    @languages.each do |lang|
      @speakers_counts[lang.id] = AudioMessage.active
        .group(:speaker_id)
        .where(["language_id = ?",lang.id])
        .count
    end
  end
  
  def speakers
    @language = Language.find(params[:id])
    @speakers = @language.speakers
    @speakers_counts = AudioMessage.active
      .group(:speaker_id)
      .where(["language_id = ?",@language.id])
      .count
    if @speakers.size > 50
      @letters = @speakers.collect(&:index_letter).sort.uniq
    end
  end

  def show
    @language = Language.find(params[:id])
    @query_title = t(:query_by_language, :language => @language.name)
    @items = AudioMessage.search('',
                                 :with => { :language_id => @language.id},
                                 :order => sort_column,
                                 :page => params[:page],
                                 :max_matches => 5000,
                                 :sql => { :include => [:language, :speaker, :place, :tags] })
    
    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end
    
  end
  
end
