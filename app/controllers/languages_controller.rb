class LanguagesController < ApplicationController

  def index
    @languages = Language.all(:order => :name)
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
    @query_title = "Messages by language #{@language.name}"
    @items = AudioMessage.search('',
                                 :with => { :language_id => @language.id},
                                 :order => sort_column,
                                 :match_mode => :boolean,
                                 :page => params[:page],
                                 :max_matches => 2500,
                                 :include => [:language, :speaker, :place])
    
    if params[:download] && download_zipline(@items,@query_title)
      return
    else
      render :template => 'welcome/index'
    end
    
  end
  
end
