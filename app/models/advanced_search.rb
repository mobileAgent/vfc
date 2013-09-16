class AdvancedSearch
  
  ADVANCED_FORM_TO_LABELS = {
    :title => :title,
    :speaker => :speaker,
    :tags => :tags,
    :event_date => :date,
    :place => :place,
    :language => :language
  }

  ADVANCED_LABELS_TO_CONDITIONS = {
    :title => :full_title,
    :speaker => :speaker_name,
    :tags => :tags,
    :date => :date,
    :place => :place,
    :language => :language
  }

  # Take parameters from the advanced search form
  # and turn it into a a fielded query string
  # Note there is no way to add non-fielded terms
  # by this mechanism but users can still type them later
  # in the basic search box
  def self.to_query_string(params)
    query_terms = []
    # Sorting the keys here is not important
    # for operations but improves testability
    ADVANCED_FORM_TO_LABELS.keys.sort.each do |k|
      v = ADVANCED_FORM_TO_LABELS[k]
      unless params[k].blank?
        query_terms << "#{v}:#{quote_term(params[k])}"
      end
    end
    query_terms.join(' ')
  end

  # quote a term when needed, i.e. if it contains spaces colons or
  # quotation marks
  def self.quote_term(term)
    term.index(/[ :"]/) ? "\"#{term.gsub(/\"/,'')}\"" : term
  end

  # Parse a potentially advanced query string into
  # a conditions array suitable for a thinking sphinx
  # finder. Note that any non-fielded terms are put
  # into
  #  conditions => query
  # and must be pulled out of there and used as the query
  # to the finder before using
  def self.to_conditions(q)
    conditions = {}
    non_fielded_terms = []
    # get any fielded terms with or without quotes and
    # any unfielded terms with or without quotes
    q.split(/([\w+]+:"[^"]+")|([\w+]+:[^" ]+)|("[^"]+")|(\w+)/).each do |term|
      next if term.strip.length == 0
      if term.index(/:/)
        field,value = term.split(/:/,2)
        cond_name = ADVANCED_LABELS_TO_CONDITIONS[field.downcase.to_sym]
        if cond_name
          if value.index(/^".+"$/)
            conditions[cond_name] = value[1..-2]
          else
            conditions[cond_name] = value
          end
        else
          non_fielded_terms << term
        end
      else
        non_fielded_terms << term
      end
    end
    if non_fielded_terms.size > 0
      conditions[:query] = non_fielded_terms.join(' ')
    end
    conditions
  end

  # Determine if a query string contains fielded terms
  # that we need to care about
  def self.is_advanced?(query)
    ADVANCED_LABELS_TO_CONDITIONS.each do |key|
      return true if query.index /#{key}:/
    end
    return false
  end

end
