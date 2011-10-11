class WelcomeController < ApplicationController

  def index
    @motms = Motm.active
    @motm = @motms.first if (@motms && @motms.size > 0)
    @tags = AudioMessage.tag_counts
  end

  def contact
  end

  def about
  end

  def search
    if request.xhr?
      @size_limit = 20
      @hits = []
      t = "%#{params[:term]}%"
      @speakers = Speaker
        .where("last_name like ? or first_name like ?",t,t)
        .limit(@size_limit-@hits.size)
        .order("last_name, first_name, middle_name")
      @hits += @speakers.map { |n| n.full_name }
      if @hits.size < @size_limit
        @places = Place
          .where("name like ?",t)
          .limit(@size_limit-@hits.size)
          .order("name")
        @hits += @places.map { |n| n.name }
      end
      if @hits.size < @size_limit
        @msgs = AudioMessage
          .where("title like ? or subj like ?",t,t)
          .limit(@size_limit-@hits.size)
          .order("title, subj")
        @hits += @msgs.map { |n| "#{n.autocomplete_title}, #{n.speaker.full_name}" }
      end
      render :text => @hits.to_json and return
    elsif params[:q]
      @query_title = params[:q]
      @items = AudioMessage.search(params[:q],
                                   :page => params[:page],
                                   :per_page => AudioMessage.per_page,
                                   :order => "#{sort_column} #{sort_direction}",
                                   :match_mode => :boolean,
                                   :max_matches => 2500,
                                   :include => [:language, :speaker, :place])
      render :action => :index
    end
  end

end
