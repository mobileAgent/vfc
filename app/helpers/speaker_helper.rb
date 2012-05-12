module SpeakerHelper

  def generate_speaker_list_with_counts
    speakers = Speaker.active.order('last_name,first_name')
    message_counts = AudioMessage.active.group(:speaker_id).count
    list = []
    speakers.each do |s|
      if message_counts[s.id] && message_counts[s.id] > 0
        list << OpenStruct.new(:full_name => s.full_name,
                               :catalog_name => s.catalog_name,
                               :speaker_id => s.id,
                               :index_letter => s.index_letter,
                               :count => message_counts[s.id])
      end
    end
    list
  end
end
