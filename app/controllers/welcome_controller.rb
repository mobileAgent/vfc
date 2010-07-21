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
      @items = AudioMessage.search(params[:q], :limit => 500)
      flash.now[:notice] = "Found #{@items.size} items matching '#{params[:q]}'"
      render :action => :index
    end
  end

end
