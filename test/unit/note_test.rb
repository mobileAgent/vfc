require 'test_helper'

class NoteTest < Test::Unit::TestCase

  def test_file_extension
    n = FactoryGirl.build(:note)
    assert_equal "pdf",n.filetype,"Note filetype"
  end
end
