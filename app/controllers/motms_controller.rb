class MotmsController < ApplicationController

  def index
    # Users language
    @motms = Motm.language(@language)

    # Other languages
    if @motms.size < 30
      @other_motms = Motm.not_language(@language)
    else
      @other_motms = []
    end
  end
  
end
