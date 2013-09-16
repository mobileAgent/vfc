require 'test_helper'

class SpeakerHelperTest < Test::Unit::TestCase

  include SpeakerHelper
  
  # If we mock this out too much we wont be testing
  # the count query and order so go ahead and create
  # some records
  def test_speaker_list_generation
    s1 = FactoryGirl.create(:speaker, :last_name => "Ttt", :first_name => "Sssss")
    s2 = FactoryGirl.create(:speaker, :last_name => "Zzz", :first_name => "Aaaaa")

    a1 = 10.times.inject([]) { |a,x| a <<  FactoryGirl.create(:audio_message, :title => "Message Title #{x}", :subj => "The Subject #{x}", :speaker => s1) }
    a2 = 5.times.inject([]) { |a,x| a <<  FactoryGirl.create(:audio_message, :title => "Message Title #{x}", :subj => "The Subject #{x}", :speaker => s2) }

    speaker_list = generate_speaker_list_with_counts
    assert  speaker_list.size >= 2,"Speaker list should have at least two items"
    a1_pos = -1
    a2_pos = -2
    speaker_list.each_with_index do |speaker,i|
      if speaker.last_name == "Ttt"
        assert_equal 10,speaker.active_message_count,"Counts should be calculated for active messages of speaker 1"
        a1_pos = i
      elsif speaker.last_name == "Zzz"
        assert_equal 5,speaker.active_message_count,"Counts should be calculated for active messages of speaker 2"
        a2_pos = i
      end
    end
    assert a1_pos >= 0,"List must contain speaker 1"
    assert a2_pos >= a1_pos,"List must container speaker 2 after speaker 1"
  end
  
end
