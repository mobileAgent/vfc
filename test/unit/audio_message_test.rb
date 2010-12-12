require 'test_helper'

class AudioMessageTest  < Test::Unit::TestCase

  def test_title_formatting
    a = Factory.build(:audio_message)
    assert a.full_title == "Message Title ~ The Subject", "Proper title formatting"
  end

  def test_year_extraction
    a = Factory.build(:audio_message, :event_date => Date.parse("1986-09-06"))
    assert_equal 1986,a.year,"Year extraction from event date"
  end


end
    
