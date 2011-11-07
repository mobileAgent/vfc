class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all # include all helpers, all the time
  before_filter :load_cacheable_data
  helper_method :sort_column, :sort_column_ar, :sort_direction
  
  # To test 404 routing in development, use this
  # alias_method :rescue_action_locally, :rescue_action_in_public

  protected
  
  def render_optional_error_file(status_code)
    if status_code == :not_found
      render_404
    else
      super
    end
  end

  def load_cacheable_data
    @tagline = 
      Rails.cache.fetch("tagline",:expires => 30.minutes) {
        "#{AudioMessage.active.count} messages, #{Speaker.count} speakers, #{Language.count} languages"
    }
    @tagline2 = "One Lord Jesus Christ."
  end
  
  # Used for sphinx searches
  def sort_column
    f = %w(full_title speaker_name filesize duration event_date place language)
    f.include?(params[:sort]) ? params[:sort] : "speaker_name asc, full_title"
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
  
  def render_404
    respond_to do |type| 
      type.html { render :template => "errors/404", :layout => 'application', :status => 404 } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true  # so we can do "render_404 and return"
  end  
  
end
