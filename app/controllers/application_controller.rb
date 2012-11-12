class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all # include all helpers, all the time
  before_filter :set_locale
  before_filter :authorize
  before_filter :load_cacheable_data
  helper_method :sort_column, :sort_column_ar, :sort_direction
  
  include ActionController::Streaming
  include ApplicationHelper
  
  delegate :allow?, to: :current_permission
  helper_method :current_user, :allow?
  
  delegate :allow_param?, to: :current_permission
  helper_method :current_user, :allow_param?

  protected

  def load_cacheable_data
    # Cache class warmup
    Motm
    AudioMessage
    
    @tagline = 
      Rails.cache.fetch("tagline-#{@locale}",:expires_in => 30.minutes) {
        t(:tagline_html,
            :messages => AudioMessage.active.count,
            :speakers => Speaker.active.count,
            :languages => Language.count).html_safe
    }
    @tagline2 = t(:tagline2_html).html_safe

    @motm = Rails.cache.fetch("motm-#{@locale}",:expires_in => 30.minutes) {
      Motm.language(@language).active.first
    }
    
  end
 
  def set_locale
    @locale = 
      params[:locale] ||
      extract_locale_from_tld ||
      extract_locale_from_accept_language_header ||
      I18n.default_locale
    I18n.locale = @locale
    @language = Language.locale(@locale).first || Language.default.first
    logger.info "Locale set to #{@locale} language #{@language.name}"
  end
 
  def extract_locale_from_accept_language_header
    h = request.env['HTTP_ACCEPT_LANGUAGE']  
    if h && h.length > 1
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    else
      nil
    end
  end
  
  def extract_locale_from_tld
    parsed_locale = TLD_TO_LOCALE_MAP[request.host]
    logger.debug "Parsed locale from #{request.host} came out to #{parsed_locale}"
    parsed_locale ||= 'en'
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : nil
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def current_permission
    @current_permission ||= Permission.new(current_user)
  end

  def current_resource
    nil
  end
  
  def authorize
    if current_permission.allow?(params[:controller], params[:action], current_resource)
      current_permission.permit_params! params
    else
      redirect_to root_url, notice: t(:unauthorized)
    end
  end
  
end
