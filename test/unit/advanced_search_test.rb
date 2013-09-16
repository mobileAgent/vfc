require 'test_helper'

class AdvancedSearchTest < Test::Unit::TestCase

  def test_fielded_term_extraction
    c = AdvancedSearch.to_conditions("speaker:jones")
    assert_equal "jones", c[:speaker_name]
    assert_equal 1, c.size, "Wrong number of terms extracted to conditions"
  end
  
  def test_fielded_quoted_term_extraction
    c = AdvancedSearch.to_conditions("speaker:\"jimmy jack\"")
    assert_equal "jimmy jack", c[:speaker_name]
    assert_equal 1, c.size, "Wrong number of terms extracted to conditions"
  end

  def test_unfielded_quoted_term_extraction
    c = AdvancedSearch.to_conditions("\"jimmy jack\"")
    assert_equal "\"jimmy jack\"", c[:query]
    assert_equal 1, c.size, "Wrong number of terms extracted to conditions"
  end
  
  def test_unfielded_term_extraction
    c = AdvancedSearch.to_conditions("1993")
    assert_equal "1993", c[:query]
    assert_equal 1, c.size, "Wrong number of terms extracted to conditions"
  end
  
  def test_fielded_combination_extraction
    c = AdvancedSearch.to_conditions("speaker:s1 title:t1 date:d1 tags:t2 language:l1")
    assert_equal "s1", c[:speaker_name]
    assert_equal "t1", c[:full_title]
    assert_equal "d1", c[:date]
    assert_equal "t2", c[:tags]
    assert_equal "l1", c[:language]
    assert_equal 5, c.size, "Wrong number of terms extracted to conditions"
  end

  def test_fielded_and_unfielded_combination
    c = AdvancedSearch.to_conditions("speaker:s1 term1")
    assert_equal "s1", c[:speaker_name]
    assert_equal "term1", c[:query]
    assert_equal 2, c.size, "Wrong number of terms extracted to conditions"
  end

  def test_bogus_field_ends_up_as_query_term
    c = AdvancedSearch.to_conditions("xyzzy:s1")
    assert_equal "xyzzy:s1", c[:query]
  end

  def test_form_params_renamed_and_joined
    q = AdvancedSearch.to_query_string(:title => "t1", :speaker => "s1",
                                       :tags => "t2", :event_date => "d1",
                                       :place => "p1", :language => "l1")
    assert_equal "date:d1 language:l1 place:p1 speaker:s1 tags:t2 title:t1",q
  end
      
  def test_blank_form_params_not_included
    q = AdvancedSearch.to_query_string(:title => "t1", :speaker => "")
    assert_equal "title:t1",q
  end
  
end
