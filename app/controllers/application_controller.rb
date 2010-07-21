class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :password

  before_filter :tagline

  private

  def tagline
    @tagline = Rails.cache.fetch("tagline",:expires => 30.minutes) {
      "#{AudioMessage.active.count} messages by #{Speaker.count} speakers in #{Language.count} langauges - One Lord Jesus Christ." }
  end

end
