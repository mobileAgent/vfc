class TagsController < ApplicationController

  def show
    @query_title = "Messages tagged with #{params[:id]}"
    @page_title = "Tag #{params[:id]}"
    @items = AudioMessage.search('',
                :conditions => {:tags => params[:id]},
                :page => params[:page] || 1,
                :per_page => AudioMessage.per_page,
                :order => "#{sort_column} #{sort_direction}",
                :include => [:language, :speaker, :place])
    logger.debug "Found #{@items.size} items"
    render :template => 'welcome/index'
  end
  
end
