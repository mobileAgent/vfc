module ApplicationHelper

  include TagsHelper

  def icon(s, options = {})
    image_tag("icons/#{s}.png",options)
  end

  def flag(s,options = {})
    image_tag("flags/#{s}.png",options)
  end

  def flags_for_lang(lang, options = {})
    options[:alt] = "#{lang} language" unless options[:alt]
    options[:title] = "#{lang} language" unless options[:title]
    image_tag("language-flags/#{lang.downcase}.png",options)
  end

  def sort_link_to(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    url = url_for(params.merge({:sort => column, :direction => direction}))
    link_to title, url,
          {:class => css_class}
  end

end
