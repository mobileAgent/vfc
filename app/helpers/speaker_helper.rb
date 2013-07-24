module SpeakerHelper

  def generate_speaker_list_with_counts
    speakers = Speaker.active.order('last_name,first_name,middle_name')
    message_counts = AudioMessage.active.group(:speaker_id).count
    speakers.each do |s|
      if message_counts[s.id] && message_counts[s.id] > 0
        s.active_message_count = message_counts[s.id]
      end
    end
    speakers
  end
end
