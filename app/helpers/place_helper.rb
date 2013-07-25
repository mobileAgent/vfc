module PlaceHelper

  def generate_place_list_with_counts
    places = Place.order('name')
    message_counts = AudioMessage.active.group(:place_id).count
    speaker_counts = AudioMessage.active.group(:place_id,:speaker_id).count
    place_map = {}
    list = []
    places.each do |p|
      if message_counts[p.id]
        p.active_message_count = message_counts[p.id]
      end
      place_map[p.id] = p
    end
    speaker_counts.each do |k,v|
      if k[0] && place_map[k[0]]
        place_map[k[0]].active_speaker_count ||= 0
        place_map[k[0]].active_speaker_count += 1
      end
    end
    places
  end

  def generate_place_speaker_list_with_counts(place)
    speakers = place.speakers.active.order(:last_name, :first_name)
    speaker_counts = AudioMessage.active.where("place_id = #{place.id}").group(:speaker_id).count
    speakers.each do |s|
      if speaker_counts[s.id]
        s.active_message_count = speaker_counts[s.id]
      end
    end
    speakers
  end
end
