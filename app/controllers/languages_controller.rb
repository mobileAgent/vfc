class LanguagesController < ApplicationController

  def index
    @languages = Language.all(:order => :name)
    @speakers_by_language = {}
    @languages.each do |language|
      @speakers_by_language[language.name] =
        AudioMessage.active.all(:group => :speaker_id,
                         :conditions => ["language_id = ?",language.id],
                         :limit => 10,
                         :order => :add_date)
    end
  end

  def show
    @language = Language.find(params[:id])
    @query_title = "Messages by language #{@language.name}"
    @items = AudioMessage.active.paginate(:page => params[:page],
                                          :conditions => ["language_id = ?",@language.id],
                                          :order => 'speaker_id,msg,subj',
                                          :include => [:language, :speaker, :place])
    render :template => 'welcome/index'
  end
  
end
