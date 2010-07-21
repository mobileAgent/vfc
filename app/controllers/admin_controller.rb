class AdminController < ApplicationController

  before_filter :authenticate
  
  def show
    if params[:q]
      @items = AudioMessage.search(params[:q], :limit => 500)
    end

    if request.xhr?
      render :text => @items.to_json
    else
      respond_to do |format|
        format.html # show.html.erb
        format.json  { render :text => @items.to_json}
        format.xml { render :xml => @items }
      end
    end
  end

end
