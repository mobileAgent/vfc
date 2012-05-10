require 'test_helper'
require 'will_paginate/array'

class AdminControllerTest < ActionController::TestCase
  
  def setup
    @user = FactoryGirl.create(:user,:admin => true )
    session[:user_id] = @user.id
  end
  
  test "authenticate as admin" do
    @collection = []
    10.times { |i| @collection << FactoryGirl.create(:audio_message, :speaker => @speaker) }
    @paginated_collection = @collection.paginate
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :show, :q => 'Abraham'
    assert_response :success
  end

end
