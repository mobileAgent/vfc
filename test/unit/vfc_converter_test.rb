require 'test_helper'

class VfcConverterTest < Test::Unit::TestCase

  include VfcConverter # the module under test

  def test_place_locator
    name = "Neverland"
    p = Place.find_by_name(name) || FactoryGirl.create(:place, :name => name)
    assert_equal p.id,place_locator(p.name).id,"Place must be found by locator using name"
    assert_equal p.id,place_locator(p.name[0..4]).id,"Place must be found by locator using partial name"
  end

  def test_place_locator_can_create
    assert place_locator("North Umbria"),"Place should be created if it doesn't exist"
  end

  def test_place_locator_handles_null
    assert_nil place_locator,"Place locator returns nill for no arg"
    assert_nil place_locator(""),"Place locator returns nill for blank arg"
  end

  # Some type of transactional issue perhaps? 
  #def test_language_converter
  #  name = "NorthUmbrian"
  #  l = Language.find_by_name(name) || FactoryGirl.create(:language, :name => name)
  #  found = converted_language(name)
  #  assert_equal l.id,found.id,"Language must be found by name when it exists, not #{found.inspect}"
  #end

  def test_language_cannot_be_created_through_conversion
    assert_equal "English",converted_language("Chunky Bacon").name,"New languages are not created by conversion, must return English"
  end

  def test_language_converter_with_french
    assert_equal "French",converted_language("French").name,"French is a recognized language"
  end
  
  def test_language_converter_with_spanish
    assert_equal "Spanish",converted_language("Spanish").name,"Spanish is a recognized language"
  end
  
  def test_language_converter_with_portuguese
    assert_equal "Portuguese",converted_language("Portuguese").name,"Portuguese is a recognized language"
  end

  def test_converted_duration
    assert_equal 66,converted_duration("01:06"),"Converted duration must handle mm:ss"
  end
  
  def test_converted_duration_with_hours
    assert_equal 66,converted_duration("00:01:06"),"Converted duration must handle hh:mm:ss"
  end

  def test_language_converter_with_default
    assert_equal converted_language.name,"English","English is the default converted language"
  end

  def test_event_date_conversion_with_year_only
    assert_equal "2001-01-01",converted_event_date("2001").strftime("%Y-%m-%d"),"Event date must be converted from year"
  end
  
  def test_event_date_conversion_from_year_with_dashes
    assert_equal "2001-01-01",converted_event_date("--2001--").strftime("%Y-%m-%d"),"Event date must be converted from year with dashes"
  end
  
  def test_event_date_conversion_from_slashed_yyyymmdd
    assert_equal "2001-02-01",converted_event_date("02/01/01").strftime("%Y-%m-%d"),"Event date must be converted from year with slashes"
  end
  
  def test_event_date_conversion_from_iso8601
    assert_equal "2002-03-04",converted_event_date("2002-03-04").strftime("%Y-%m-%d"),"Event date must be converted from iso 8601 format"
  end

end
