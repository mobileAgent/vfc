require 'test_helper'

class AudioMessageTest  < Test::Unit::TestCase

  def test_title_formatting
    a = FactoryGirl.build(:audio_message, :title => "Message Title", :subj => "The Subject")
    assert_equal "Message Title ~ The Subject", a.full_title
  end

  def test_year_extraction
    a = FactoryGirl.build(:audio_message, :event_date => Date.parse("1986-09-06"))
    assert_equal 1986,a.year,"Year extraction from event date"
  end


end
    
