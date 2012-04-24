class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all # include all helpers, all the time
  before_filter :load_cacheable_data
  helper_method :sort_column, :sort_column_ar, :sort_direction
  
  include ApplicationHelper
  
  protected

  def load_cacheable_data
    # Cache class warmup
    Motm
    AudioMessage
    
    @tagline = 
      Rails.cache.fetch("tagline",:expires => 30.minutes) {
        "#{AudioMessage.active.count} messages, #{Speaker.count} speakers, #{Language.count} languages"
    }
    @tagline2 = "One Lord Jesus Christ."
  end
  

end
