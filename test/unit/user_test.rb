require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_normal_user_is_valid
    u = FactoryGirl.build(:user)
    assert u.valid?
  end
  
end
