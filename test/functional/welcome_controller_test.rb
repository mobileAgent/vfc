require 'test_helper'
require 'will_paginate/array'

class WelcomeControllerTest < ActionController::TestCase

  test "should get home page" do
    Rails.cache.delete('tagline')
    Rails.cache.delete('tag_cloud')
    get :index
    assert_response :success
    assert Rails.cache.read('tagline-en'), "Tagline must be cached by locale"
    assert Rails.cache.read('tag_cloud'),"Tag Cloud must be cached"
    assert assigns(:tagline),"Tagline must be assigned"
    assert assigns(:tag_cloud),"Tag Cloud must be available for home page render"
  end

  test "should get home page with motm" do
    Rails.cache.delete('motm')
    motm = FactoryGirl.create(:motm)
    get :index
    assert_response :success
    assert_not_nil assigns(:motm)
    assert Rails.cache.read('motm')
    assert assigns(:motm), "Motm must be assigned when available"
  end

  test "autocomplete speaker name" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :autocomplete, :term => a.speaker.last_name
    assert_response :success
  end

  test "search by last name" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, :q => a.speaker.last_name
    assert_response :success
  end
  
  test "download responds with zip file" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    FileFile.expects(:new).at_least_once.returns(nil)
    post :search, :q => a.speaker.last_name, :download => true
    assert_response :success
    assert_equal 'application/zip',response.header['Content-Type']
  end
  
  test "search by full name assigns bio" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, :q => a.speaker.full_name
    assert_response :success
    assert assigns(:speaker), "No speaker was assigned"
  end

  test "search without param goes to home page" do
    get :search
    assert_response :redirect
  end

  test "search that returns nothing redirects to home page" do
    AudioMessage.expects(:search).returns([].paginate)
    get :search, :q => 'xyzzy'
    assert_response :redirect 
  end

  test "show a message without optional fields" do
    a = FactoryGirl.create(:audio_message, :event_date => nil, :place => nil)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, :q => 'blah'
    assert_response :success
  end
  
  test "show a message with optional fields" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, :q => 'blah'
    assert_response :success
  end

end
