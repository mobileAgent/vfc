require 'test_helper'

class MotmsControllerTest < ActionController::TestCase

  test "should get list" do
    Rails.cache.delete('motm')
    (1..10).each { |n| FactoryGirl.create(:motm) }
    get :index
    assert_response :success
    assert Rails.cache.read('motm')
  end

end
