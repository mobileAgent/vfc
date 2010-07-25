class WelcomeController < ApplicationController
  
  def index
    @motms = Motm.active
    @motm = @motms.first if (@motms && @motms.size > 0)
    @motm ||= AudioMessage.find(1604)
  end

  def contact
  end

  def about
  end

  def search
    if params[:q]
      @items = AudioMessage.search(params[:q], :page => params[:page], :per_page => 50,  :order => 'speaker_last_name ASC, speaker_first_name ASC, msg ASC, subj ASC', :match_mode => :boolean)
      flash.now[:notice] = "Found #{@items.total_entries} messages matching '#{params[:q]}'"
      render :action => :index
    end
  end

end
