require 'test_helper'

class AudioMessageTest  < Test::Unit::TestCase

  def test_title_formatting
    a = FactoryGirl.build(:audio_message, :title => "Message Title", :subj => "The Subject")
    assert_equal "Message Title ~ The Subject", a.full_title
  end

  def test_player_title_formatting
    speaker = FactoryGirl.build(:speaker, :last_name => "Jack", :first_name => "Jimmy")
    a = FactoryGirl.build(:audio_message, :title => "Message Title", :subj => "The Subject", :speaker => speaker)
    assert_equal "J Jack ~ Message Title ~ The Subject", a.player_title
  end
  
  def test_title_formatting_with_no_subject
    a = FactoryGirl.build(:audio_message, :title => "Message Title", :subj => nil)
    assert_equal "Message Title", a.full_title
  end
  
  def test_autocomplete_title
    a = FactoryGirl.build(:audio_message, :title => "I 'Am' The Door (John)", :subj => nil)
    assert_equal "I Am The Door John", a.autocomplete_title
  end

  def test_year_extraction
    a = FactoryGirl.build(:audio_message, :event_date => Date.parse("1986-09-06"))
    assert_equal 1986,a.year,"Year extraction from event date"
  end
  
  def test_human_date
    a = FactoryGirl.build(:audio_message, :event_date => Date.parse("1986-09-06"))
    assert_equal "1986-09-06" ,a.human_date,"Year extraction from event date"
  end
  
  def test_human_date_for_default_month_and_day
    a = FactoryGirl.build(:audio_message, :event_date => Date.parse("1986-01-01"))
    assert_equal "-- 1986 --" ,a.human_date,"Year extraction from event date"
  end

  def test_year_extraction_for_nil
    a = FactoryGirl.build(:audio_message, :event_date => nil)
    assert_nil a.year,"Year extraction from nil event date"
  end

  def test_human_readable_duration
    a = FactoryGirl.build(:audio_message, :duration => (60 * 100) + 2)
    assert_equal "01:40:02",a.human_duration
  end

  def test_human_filesize
    a = FactoryGirl.build(:audio_message, :filesize => (1024 * 10) + 100)
    assert_equal "10 kb",a.human_filesize
  end

  def test_human_filesize_for_nil
    a = FactoryGirl.build(:audio_message, :filesize => nil)
    assert_equal "0",a.human_filesize
  end

  def test_human_filesize_for_large_file
    a = FactoryGirl.build(:audio_message, :filesize => (1024 * 1024 * 3) + 100)
    assert_equal "3 mb",a.human_filesize
  end

  def test_download_filename
    s = FactoryGirl.build(:speaker, :first_name => "Jimmy", :last_name => "Jack", :middle_name => nil)
    a = FactoryGirl.build(:audio_message, :speaker => s, :title => "A Lasting Impression")
    assert_equal "jack-jimmy-a-lasting-impression.mp3",a.download_filename
  end
  
  def test_playlist_name
    s = FactoryGirl.build(:speaker, :first_name => "Jimmy", :last_name => "Jack", :middle_name => nil)
    a = FactoryGirl.build(:audio_message, :speaker => s, :title => "A Lasting Impression", :subj => nil)
    assert_equal "Jack Jimmy - A Lasting Impression",a.playlist_name
  end

  def test_create_audio_with_place_relationship
    s = FactoryGirl.create(:speaker, :first_name => "Jimmy", :last_name => "Jack", :middle_name => nil)
    p = FactoryGirl.create(:place, :name => "Mars Hill")
    a = FactoryGirl.create(:audio_message, :speaker => s, :title => "A Lasting Impression", :subj => nil, :place => p)
    assert_equal p.id,a.place_id,"Place relationship must be saved"
  end


end
    
