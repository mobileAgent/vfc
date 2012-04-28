require 'test_helper'

class MotmsControllerTest < ActionController::TestCase

  test "should get list" do
    (1..10).each { |n| FactoryGirl.create(:motm) }
    get :index
    assert_response :success
  end

end
