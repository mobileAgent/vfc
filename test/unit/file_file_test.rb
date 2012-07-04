require 'test_helper'

class FileFileTest < Test::Unit::TestCase
  
  def test_file_file_opener
    f = FileFile.new("#{Rails.root}/config/environment.rb")
    ff = f.file 
    assert ff.path.index /environment.rb/
  end
  
end
