module AudioMessageHelper

  def optional_cell(v)
    if v && v.respond_to?(:name)
      "<td>#{v.name}</td>".html_safe
    elsif v
      "<td>#{v}</td>".html_safe
    else
      "<td class='ua'>unavailable</td>".html_safe
    end
  end
end
