class AudioMessagesController < ApplicationController

  before_action :check_blocked_hosts

  def show
    unless current_resource
      redirect_to root_url, notice: t(:nsr)
      return
    end
    unless audio_access_allowed?
      if AudioGate.app_request?(request.user_agent) || app_signature.present?
        # The app would save a redirect's HTML as the mp3, so fail outright.
        head :too_many_requests
      else
        # Stale or missing link: send people to a page with fresh ones.
        redirect_to(current_resource.speaker ? speaker_url(current_resource.speaker) : root_url)
      end
      return
    end
    file_path = AUDIO_PATH + current_resource.filename
    unless File.exist?(file_path)
      logger.info "Missing file path for audio #{file_path}"
      redirect_to root_url, warning: t(:nsf)
      return
    end
    mime_type = params[:dl] ? AUDIO_MIME_DL : AUDIO_MIME_PLAY
    logger.info "AUDIO_SERVE id=#{params[:id]} range=#{request.headers['HTTP_RANGE'].inspect} ua=#{request.user_agent.to_s[0, 80]}"
    serve_with_ranges(file_path, mime_type, current_resource.download_filename)
  end

  def client_diagnostic
    logger.warn "CLIENT_DIAGNOSTIC event=#{params[:event]} url=#{params[:url]} ua=#{params[:ua].to_s[0, 120]}"
    head :ok
  end

  def delete
    @am = current_resource
    @am.update(:publish => false)
    redirect_to (request.env["HTTP_X_XHR_REFERER"] || request.env["HTTP_REFERER"] || root_url),
          notice: "Deleted #{@am.speaker.catalog_name} #{@am.full_title} (#{@am.id})"
  end

  def gold
    @mp3 = current_resource
    if @mp3
      # Old static-site links now land on the speaker's page; handing out a
      # signed file URL here would let anyone with a filename skip the gate.
      redirect_to(@mp3.speaker ? speaker_url(@mp3.speaker) : root_url) and return
    else
      redirect_to root_url, notice: t(:nsf)
    end
  end

  def edit
    @places = Place.order(:name)
    @speakers = Speaker.active.order(:last_name,:first_name)
    @languages = Language.order(:name)
    @audio_message = current_resource
  end

  def update
    @audio_message = current_resource
    referer = params[:referer][:url] if (params[:referer] && params[:referer][:url])
    if @audio_message.update(audio_message_params)
      flash[:notice] = t(:updated)
    end
    if referer
      redirect_to referer and return
    else
      redirect_to edit_audio_message_url(@audio_message) and return
    end
  end

  protected
  
  def check_blocked_hosts
    @blocked_hosts = Rails.cache.fetch("blocked_hosts",:expires_in => 30.minutes) {
      BlockedHost.all.inject([]) { |arr,bh| arr << bh.ip_address }
    }
    if @blocked_hosts.include?(request.remote_ip)
      logger.debug "Blocked host #{request.remote_ip} attempted mp3 access"
      redirect_to root_url
      return false
    end
    return true
  end

  # A signed request from the mobile app, a token from one of our pages, or
  # an older app build within its user-agent budget.
  def audio_access_allowed?
    if app_signature.present?
      problem = AudioGate.app_signature_problem(app_signature, current_resource.id)
      if problem.nil?
        return true if AudioGate.signed_app_allowance?
        return deny_audio('signed_app_budget')
      end
      # Fall through to the checks below, so a build with a retired key
      # keeps working within the user-agent budgets.
      log_audio_gate("app_signature #{problem}")
    end
    if AudioGate.app_request?(request.user_agent)
      return true if AudioGate.app_allowance?(request.remote_ip)
      return deny_audio('app_budget')
    end
    problem = AudioGate.token_problem(params[:t], current_resource.id, request.remote_ip)
    problem ? deny_audio(problem) : true
  end

  def app_signature
    request.headers[AudioGate::APP_SIGNATURE_HEADER]
  end

  def deny_audio(reason)
    log_audio_gate("deny reason=#{reason}")
    false
  end

  def log_audio_gate(what)
    logger.warn "AUDIO_GATE #{what} id=#{current_resource.id} ip=#{request.remote_ip} " \
                "ref=#{request.referer.to_s[0, 80]} ua=#{request.user_agent.to_s[0, 80]}"
  end

  def current_resource
    begin
      if params[:action] == "gold"
        path = params[:speaker_name] + "/" + params[:filename] + ".mp3"
        @current_resource = AudioMessage.where('publish = ? and filename = ?', true, path).first
      elsif params[:id]
        @current_resource ||= AudioMessage.where('publish = ?', true).find(params[:id])
      end
    rescue
    end
  end

  private

  def serve_with_ranges(file_path, mime_type, filename)
    disposition = params[:dl] ? 'attachment' : 'inline'
    file_size   = File.size(file_path)
    range       = request.headers['HTTP_RANGE']

    response.headers['Accept-Ranges'] = 'bytes'

    if range&.start_with?('bytes=')
      first, last = range.sub('bytes=', '').split('-', 2).map { |s| s.empty? ? nil : s.to_i }
      first ||= 0
      last   = [last || file_size - 1, file_size - 1].min

      if first >= file_size || first > last
        response.headers['Content-Range'] = "bytes */#{file_size}"
        head 416 and return
      end

      length = last - first + 1
      logger.info "AUDIO_RANGE bytes #{first}-#{last}/#{file_size} id=#{params[:id]}"

      response.headers['Content-Range']       = "bytes #{first}-#{last}/#{file_size}"
      response.headers['Content-Length']      = length.to_s
      response.headers['Content-Disposition'] = "#{disposition}; filename=\"#{filename}\""
      response.content_type = mime_type
      self.status = 206

      self.response_body = Enumerator.new do |y|
        File.open(file_path, 'rb') do |f|
          f.seek(first)
          remaining = length
          while remaining > 0
            chunk = f.read([remaining, 65_536].min)
            break unless chunk
            y << chunk
            remaining -= chunk.bytesize
          end
        end
      end
    else
      send_file file_path, type: mime_type, filename: filename,
        disposition: disposition, x_sendfile: (Rails.env == 'production')
    end
  end

  def audio_message_params
    # Content fields any audio_message_editor may change.
    permitted = [:title, :subj, :groupmsg, :publish,
                 :language_id, :place_id, :speaker_id, :note_id, :event_date]
    # Protected file-metadata fields only admins may change. This replaces
    # the Rails 3.2 `attr_accessible ..., :as => :admin` role mechanism.
    permitted += [:filesize, :duration, :filename] if current_user && current_user.admin?
    params.require(:audio_message).permit(*permitted)
  end

end
