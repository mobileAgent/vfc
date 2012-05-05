require 'test_helper'

class HymnsControllerTest < ActionController::TestCase

  test "should get hymn list" do
    get :index
    assert_response :success
  end

  test "try for missing hymn" do
    get :show, :id => 100
    assert_redirected_to '/hymns'
  end

end
