class SpeakerNormalizer
  
  
  # Take the old VFC speaker_name column
  # and split it up into an [ln,fn,mn] array
  def self.normalize_old_name(s)
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
  
  # Create the normalized speakers in the speakers
  # table and update the speaker_id on all of the audio messages
  def self.normalize_old_names_and_load
    @speakers = AudioMessage.count(:group => :speaker_name, :order => :speaker_name)
    @speakers.each do |old_name|
      parts = normalize_old_name(old_name[0])
      s = Speaker.first(:conditions => ["last_name = ? and first_name = ? and middle_name = ?",parts[0],parts[1],parts[2]])
      if s
        puts "Found existing speaker #{s.inspect}"
      else
        s = Speaker.new(:last_name => parts[0],:first_name => parts[1], :middle_name => parts[2])
        s.save!
      end
      count = AudioMessage.update_all({:speaker_id => s.id}, "speaker_name = '#{old_name[0]}'")
      puts "Updated #{count} messages with id #{s.id} for #{s.full_name}"
    end
  end
end
