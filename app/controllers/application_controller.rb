class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all # include all helpers, all the time
  before_filter :load_cacheable_data
  helper_method :sort_column, :sort_column_ar, :sort_direction
  
  include ActionController::Streaming
  include ApplicationHelper
  include Zipline
  
  protected

  def load_cacheable_data
    # Cache class warmup
    Motm
    AudioMessage
    
    @tagline = 
      Rails.cache.fetch("tagline",:expires_in => 30.minutes) {
        "#{AudioMessage.active.count} messages, #{Speaker.active.count} speakers, #{Language.count} languages"
    }
    @tagline2 = "One Lord Jesus Christ."
  end
  
  def download_zipline(audio_items,query_string)
    zipfn = "vfc-" + query_string.gsub(/[^a-zA-Z0-9]+/,'-') + "-" + DateTime.now.strftime("%Y-%m-%d") + ".zip"
    begin
      logger.debug "Ziplining #{audio_items.size} mp3s for #{zipfn}"
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
