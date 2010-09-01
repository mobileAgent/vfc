class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :password

  before_filter :tagline

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
  
  def render_404
    respond_to do |type| 
      type.html { render :template => "errors/404", :layout => 'application', :status => 404 } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true  # so we can do "render_404 and return"
  end  
  
  private

  def tagline
    @tagline = Rails.cache.fetch("tagline",:expires => 30.minutes) {
      "#{AudioMessage.active.count} messages by #{Speaker.count} speakers in #{Language.count} langauges - One Lord Jesus Christ." }
  end

end
