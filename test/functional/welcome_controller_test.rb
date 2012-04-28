require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  test "should get home page" do
    get :index
    assert_response :success
  end

  test "should get home page with motm" do
    motm = FactoryGirl.create(:motm)
    get :index
    assert_response :success
    assert_not_nil assigns(:motm)
  end

end
