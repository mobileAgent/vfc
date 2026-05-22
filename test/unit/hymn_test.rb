require 'test_helper'

class HymnTest < ActiveSupport::TestCase

  def test_hymn
    h = FactoryGirl.create(:hymn)
    assert_not_nil h.filename
    assert_not_nil h.title
  end
  
end
