module AudioMessageHelper

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
