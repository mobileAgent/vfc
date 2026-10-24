module AudioMessageHelper

  # Audio links must carry a short-lived token; see AudioGate.
  def signed_audio_url(item, options = {})
    url_for({:controller => :audio_messages, :action => :show, :id => item,
             :t => AudioGate.token(item.id, request.remote_ip)}.merge(options))
  end

  def optional_cell(v)
    if v
      "<td>#{v}</td>".html_safe
    else
      unavailable_cell
    end
  end

  def unavailable_cell
    "<td class='ua'>#{I18n.t('audio.unavailable')}</td>".html_safe
  end
end
