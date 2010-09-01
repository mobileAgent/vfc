class WelcomeController < ApplicationController
  
  def index
    @motms = Motm.active
    @motm = @motms.first if (@motms && @motms.size > 0)
  end

  def contact
  end

  def about
  end

  def search
    if params[:q]
      @query_title = params[:q]
      @items = AudioMessage.search(params[:q],
                                   :page => params[:page],
                                   :order => 'speaker_last_name ASC, speaker_first_name ASC, msg ASC, subj ASC',
                                   :match_mode => :boolean,
                                   :max_matches => 2500,
                                   :include => [:language, :speaker, :place])
      render :action => :index
    end
  end

end
