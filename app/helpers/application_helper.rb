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
    if (column == params[:sort]) || (column == "speaker_name" && params[:sort].nil?)
      css_class = "current #{sort_direction}"
    else
      css_class = nil
    end
    tip = column == params[:sort] ? "click to reverse sort order" : "click to sort"
    direction = column == params[:sort] && sort_direction == "asc" ? "desc" : "asc"
    url = url_for(params.merge({:sort => column, :direction => direction}))
    link_to title, url,
          {:class => css_class, :title => tip}
  end
  
  # Used for sphinx searches
  def sort_column
    f = %w(full_title speaker_name filesize duration event_date place language)
    ps = params[:sort]
    if f.include?(ps)
      if ps == "speaker_name"
        "#{ps} #{sort_direction}, full_title asc"
      elsif %w(place language event_date).include?(ps)
        "#{ps} #{sort_direction}, speaker_name asc, full_title asc"
      else
        "#{ps} #{sort_direction}"
      end
    else
        "speaker_name asc, full_title asc"
    end
  end

  # Used for ar finders
  def sort_column_ar
    f = {
      "full_title" => "title",
      "filesize" => "filesize",
      "speaker_name" => "speakers.last_name",
      "duration" => "duration",
      "event_date" => "event_date",
      "place" => "places.name",
      "language" => "languages.name" }
    f.keys.include?(params[:sort]) ? f[params[:sort]] : "speakers.last_name asc, speakers.first_name asc, title asc, subj"
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : "asc"
  end

end
