require 'test_helper'
require 'will_paginate/array'

class SpeakersControllerTest < ActionController::TestCase

  def setup
    @speaker = FactoryGirl.create(:speaker, :last_name => "Jack", :first_name => "Jimmy", :middle_name => nil);
    @collection = []
    10.times { |i| @collection << FactoryGirl.create(:audio_message, :speaker => @speaker) }
    @paginated_collection = @collection.paginate
  end

  test "should get speaker list" do
    get :index
    assert_response :success
  end

  test "should get speaker cloud" do
    Rails.cache.delete('speaker_cloud')
    10.times { |i| s = FactoryGirl.create(:speaker); 10.times {|j| FactoryGirl.create(:audio_message, :speaker => s) } }
    get :index, :view => 'cloud'
    assert_response :success
    assert Rails.cache.read('speaker_cloud')
  end

  test "should get speaker messages by name on url" do
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :show, :id => 'JackJimmy', :sort => "full_title"
    assert_response :success
  end
  

  test "should get speaker messages by id" do
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :show, :id => @speaker.id
    assert_response :success
  end

  test "redirect on no such speaker" do
    get :show, :id => 0
    assert_response :redirect
  end

  test "speaker and place" do
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :place, :id => @speaker.id, :place_id => @collection.first.place_id
    assert_response :success
  end

  test "speaker and language" do
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :language, :id => @speaker.id, :language_id => @collection.first.language_id
    assert_response :success
  end
  
end
