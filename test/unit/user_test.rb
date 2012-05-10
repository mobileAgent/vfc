require 'test_helper'

class UserTest < Test::Unit::TestCase

  def test_normal_user_is_valid
    u = FactoryGirl.build(:user)
    assert u.valid?
  end
  
end
