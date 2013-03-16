module VfcConverter

  def place_locator(name)
    if (name.nil?  || name.blank?)
      return nil
    else
      return Place.find_or_create_by_name(name)
    end
  end

  
  def converted_speaker(full_name = speaker)
    ln,fn,mn = convert_speaker_name(full_name.strip)
    conditions = {:last_name => ln,:first_name => fn,:middle_name => mn }
    Speaker.find(:first, :conditions => conditions) || Speaker.create(conditions)
  end

  def convert_speaker_name(old_name)
    s = old_name
    if s.index(/^Van Der Puy/)
      fn = "Abe"
      ln = "Van Der Puy"
    elsif s.index(/^Van /) || s.index(/^Vande /)
      # Van Ryn August
      van,ln,fn,mn = s.split ' '
      ln = [van,ln].join(" ")
    elsif s.index(' ')
      # Garnes Arthur
      # Ironside Harry A.
      ln,fn,mn = s.split(' ')
      # Johnson S.Lewis
      # Nicholson J.B.
      if mn.nil? && fn.index('.')
        mn = fn[fn.index('.')+1..-1]
        fn = fn[0..fn.index('.')]
      end
    else
      # Assorted => Assorted
      ln = s
      fn = ""
    end
    ln.gsub!('.','') if ln
    fn.gsub!('.','') if fn
    mn.gsub!('.','') if mn
    [ln,fn,mn]
  end

  def converted_language(language_name = language)
    lang = nil
    if language_name
      if language_name.index /^Fr/
        lang = Language.find_or_create_by_name('French')
      elsif language_name.index /^Por/
        lang = Language.find_or_create_by_name('Portuguese')
      elsif language_name.index /^(Esp|Spa)/
        lang = Language.find_or_create_by_name('Spanish')
      end
    end
    lang = Language.find_or_create_by_name('English') unless lang
    lang
  end

  def converted_duration(duration_string = duration)
    seconds = 0
    if duration_string
      parts = duration_string.split /:/
      if parts.length == 3
        seconds += parts[2].to_i
        seconds += (parts[1].to_i * 60)
        seconds += (parts[0].to_i * 3600)
      elsif parts.length == 2
        seconds += parts[1].to_i
        seconds += (parts[2].to_i * 60)
      end
    end
    seconds
  end
  
  def converted_event_date(date_string = date)
    converted = nil
    if date_string.present?
      begin
        if date_string.index /--([0-9]{4})--/
          converted = DateTime.strptime(date_string,"--%Y--")
        elsif date_string =~ /^[0-9]{4}$/
          converted = DateTime.strptime(date_string,"%Y")
        elsif date_string.index /^[0-9]{2}\/[0-9]{2}\/([0-9]{2})$/
          converted = DateTime.strptime(date_string,"%m/%d/%y")
          converted = converted.years_ago(100) if converted.year > DateTime.now.year
        end
      rescue 
        $stderr.puts "Cannot convert date #{date_string}"
      end
    end
    converted
  end
  
end
