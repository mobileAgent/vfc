module ApplicationHelper

  include TagsHelper
  include Zipline
  
  def icon(s, options = {})
    image_tag("icons/#{s}.png",options)
  end

  def flags_for_lang(lang, options = {})
    options[:alt] = "#{lang} language" unless options[:alt]
    options[:title] = "#{lang} language" unless options[:title]
    image_tag("language-flags/#{lang.downcase}.png",options)
  end

  def sort_link_to(column, title = nil)
    title ||= column.titleize
    if (column == params[:sort]) || (column == "speaker_name" && params[:sort].nil?)
      css_class = "current #{sort_direction}"
    else
      css_class = nil
    end
    tip = column == params[:sort] ? "click to reverse sort order" : "click to sort"
    direction = column == params[:sort] && sort_direction == "asc" ? "desc" : "asc"
    url = url_for(params.merge({:sort => column, :direction => direction}))
    link_to title, url,
          {:class => css_class, :title => tip}
  end
  
  # Used for sphinx searches
  def sort_column
    f = %w(full_title speaker_name filesize duration event_date place language)
    ps = params[:sort]
    if f.include?(ps)
      if ps == "speaker_name"
        "#{ps} #{sort_direction}, full_title asc"
      elsif %w(place language event_date).include?(ps)
        "#{ps} #{sort_direction}, speaker_name asc, full_title asc"
      else
        "#{ps} #{sort_direction}"
      end
    else
        "speaker_name asc, full_title asc"
    end
  end

  # Used for ar finders
  def sort_column_ar
    f = {
      "full_title" => "title",
      "filesize" => "filesize",
      "speaker_name" => "speakers.last_name",
      "duration" => "duration",
      "event_date" => "event_date",
      "place" => "places.name",
      "language" => "languages.name" }
    f.keys.include?(params[:sort]) ? f[params[:sort]] : "speakers.last_name asc, speakers.first_name asc, title asc, subj"
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : "asc"
  end

  def authorize
    if !session[:user_id] || !User.find_by_id(session[:user_id])
      session[:original_uri] = request.url
      flash[:notice] = "Please log in for access"
      redirect_to(:controller => "login", :action => "login") and return
    end
    @current_user = User.find_by_id(session[:user_id])
    session[:user] = @current_user
    # login( link_to @curent_user.email, '/account')
  end

  def authorize_admin
    session[:original_uri] = request.url
    if session[:user_id]
      user = User.find_by_id(session[:user_id])
      unless user && user.admin?
        redirect_to root_path and return
      end
    else
      redirect_to root_path and return
    end
    @current_user = User.find_by_id(session[:user_id])
    session[:user] = @current_user
    # login( link_to @curent_user.email, '/account')
  end

  
  def download_zipline(audio_items,query_string,page=1)
    page = 1 if page.blank?
    page = page.to_i
    zipfn = "vfc-" + query_string.gsub(/[^a-zA-Z0-9]+/,'-') + "-" + DateTime.now.strftime("%Y-%m-%d") + (page > 1 ? "-#{page}" : "") + ".zip"
    begin
      logger.info "Zipline #{audio_items.size} mp3s for #{zipfn}"
      downloads = audio_items.map{ |mp3| [FileFile.new(AUDIO_PATH + mp3.filename),mp3.download_filename] }
      zipline( downloads, zipfn )
      true
    rescue
      logger.info "Zipline failed for #{audio_items.size} items #{$!}"
      flash[:notice] = "Sorry we had trouble with that request. Try them individually"
      false
    end
  end


end
