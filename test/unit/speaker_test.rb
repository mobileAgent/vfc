require 'test_helper'

class SpeakerTest  < Test::Unit::TestCase
  
  def test_with_middle_name
    s = FactoryGirl.build(:speaker, :last_name => "Jack", :first_name => "Jimmy", :middle_name => "J")
    assert_equal "Jimmy J Jack", s.full_name
    assert_equal "Jack, Jimmy J", s.catalog_name
    assert_equal "J", s.index_letter
    assert_equal "Jack_Jimmy_J", s.audio_directory_name
  end
  
  def test_nil_middle_name
    s = FactoryGirl.build(:speaker, :last_name => "Jack", :first_name => "Jimmy", :middle_name => nil)
    assert_equal "Jimmy Jack", s.full_name
    assert_equal "Jack, Jimmy", s.catalog_name
    assert_equal "J Jack", s.abbreviated_name
    assert_equal "J", s.index_letter
    assert_equal "Jack_Jimmy", s.audio_directory_name
  end

  def test_nil_first_and_middle_name
    s = FactoryGirl.build(:speaker, :last_name => "Assorted", :first_name => nil , :middle_name => nil)
    assert_equal "Assorted", s.full_name
    assert_equal "Assorted", s.catalog_name
    assert_equal "Assorted", s.abbreviated_name
    assert_equal "A", s.index_letter
    assert_equal "Assorted", s.audio_directory_name
  end

  def test_bio_processing
    s = FactoryGirl.build(:speaker, :bio => "*Jimmy Jack* is the man")
    assert s.bio_html.index(/<em>Jimmy Jack<\/em>/),s.bio_html
  end

end
