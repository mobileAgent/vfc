class TagsController < ApplicationController

  def show
    @query_title = "Messages tagged with #{params[:id]}"
    @items = AudioMessage.find_tagged_with(params[:id],
                     :include => [:language, :speaker, :place])
    render :template => 'welcome/index'
  end
  
end
