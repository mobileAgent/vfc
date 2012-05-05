require 'test_helper'
require 'will_paginate/array'

class PlacesControllerTest < ActionController::TestCase

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

end
