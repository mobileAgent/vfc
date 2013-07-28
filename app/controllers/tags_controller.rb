class TagsController < ApplicationController

  def show
    @query_title = t(:query_by_tag, :tagname => params[:id])
    @page_title = params[:id]
    @items = AudioMessage.search('',
                :conditions => {:tags => params[:id]},
                :page => params[:page] || 1,
                :per_page => AudioMessage.per_page,
                :order => sort_column,
                :include => [:language, :speaker, :place, :tags])
    logger.debug "Found #{@items.size} items"

    if request.post? && params[:download] && download_zipline(@items,@query_title,params[:page])
      return
    else
      render :template => 'welcome/index'
    end

  end
  
end
