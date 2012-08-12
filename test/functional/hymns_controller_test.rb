require 'test_helper'

class HymnsControllerTest < ActionController::TestCase

  test "should get hymn list" do
    get :index
    assert_response :success
  end

  test "try for missing hymn" do
    h = FactoryGirl.create(:hymn)
    get :show, :id => h.id
    assert_redirected_to '/hymns'
  end

end
