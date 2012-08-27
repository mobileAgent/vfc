require 'test_helper'
require 'will_paginate/array'

class PlacesControllerTest < AuthenticatedTest

  def setup
    @collection = []
    10.times { |i| @collection << FactoryGirl.create(:audio_message) }
    @paginated_collection = @collection.paginate
  end
  
  test "should get place list" do
    get :index
    assert_response :success
  end

  test "should get speaker list for place" do
    @a = FactoryGirl.create(:audio_message)
    get :speakers, :id => @a.place_id
    assert_response :success
  end

  test "show place messages by id" do
    @a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :show, :id => @a.place_id, :sort => "event_date"
    assert_response :success
  end
  
  test "show place messages by name" do
    @a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :show, :id => @a.place.name, :sort => "speaker_name"
    assert_response :success
  end
  
  test "attempt to view unknown place by name" do
    get :show, :id => 'Xyzzy'
    assert_response :redirect
  end
  
  test "new place page available to admin" do
    login(true)
    get :new
    assert_response :success
    assert_not_nil assigns(:place)
  end
  
  test "new place page not available to non-admin" do
    login
    get :new
    assert_response :redirect
  end

  test "create new place post" do
    login(true)
    assert_difference('Place.count') do
      post :create, :place => FactoryGirl.attributes_for(:place)
    end
  end

  test "edit place" do
    login(true)
    @place = FactoryGirl.create(:place)
    get :edit, :id => @place.id
    assert_response :success
    assert_not_nil assigns(:place)
  end

  test "update place" do
    login(true)
    @place = FactoryGirl.create(:place)
    @place.name = "AnotherPlace"
    post :update, :id => @place.id, :place => @place.attributes
    assert_response :redirect
    assert_not_nil assigns(:place)
    assert_equal "AnotherPlace",Place.find(@place.id).name
  end

end
