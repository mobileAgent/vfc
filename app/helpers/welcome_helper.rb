module WelcomeHelper

  def biography_tag(speaker, limit=500)
    full_bio = speaker.bio_html
    s = ""
    full_style = ""
    if full_bio.length > limit
      trunc = full_bio.index(/\s/,limit)
      s << "<div id='short-bio-#{speaker.id}'class='short-bio'>#{full_bio[0..trunc]}"
      s << "&hellip; <span class='moreless'>Read More</span>"
      s << "</div>"
      full_style = "style='display:none'"
    end
    s << "<div id='full-bio-#{speaker.id}' class='full-bio' #{full_style}>#{full_bio}"
    s << "<span class='lessmore'>Collapse</span>"
    s << "</div>"
    s.html_safe
  end
  
end
    
