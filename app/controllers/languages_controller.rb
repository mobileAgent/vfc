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
  
end
