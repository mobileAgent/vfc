module DateHelper

  def generate_speaker_list_with_counts_for_date(date,date_format,field)
    speakers = Speaker.active
      .joins(:audio_messages)
      .order("last_name, first_name, middle_name")
      .where("date_format(audio_messages.#{field},#{date_format}) = ?", date)
      .group("speakers.id")
    message_counts = AudioMessage.active
      .where("date_format(#{field},#{date_format}) = ?",date)
      .group(:speaker_id)
      .count
    
    speakers.each do |s|
      if message_counts[s.id] && message_counts[s.id] > 0
        s.active_message_count = message_counts[s.id]
      end
    end
    speakers
  end
end
