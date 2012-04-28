require 'test_helper'

class HymnTest < Test::Unit::TestCase

  # The hymn model is the lamest ever but 
  # just make sure it doesnt have a syntax error
  def test_hymn_size
    assert Hymn.all.size > 0
  end
  
end
