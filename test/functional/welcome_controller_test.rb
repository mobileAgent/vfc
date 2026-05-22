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
    l = Language.default.first || FactoryGirl.create(:language)
    Rails.cache.delete("motm-#{l.cc}")
    a = FactoryGirl.create(:audio_message, :language => l)
    motm = FactoryGirl.create(:motm, :audio_message => a)
    get :index
    assert_response :success
    assert_not_nil assigns(:motm),"Motm should be assigned for #{assigns(:locale)} since we have #{motm.audio_message.language.name} for a #{motm.inspect}"
    assert Rails.cache.read("motm-#{l.cc}"),"Motm should be cached by language/locale"
    assert assigns(:motm), "Motm must be assigned when available"
  end

  test "autocomplete speaker name" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :autocomplete, params: { :term => a.speaker.last_name }
    assert_response :success
  end

  test "search by last name" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, params: { :q => a.speaker.last_name }
    assert_response :success
  end
  
  test "download responds with zip file" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    # Rails 5 streams the zip lazily (read during response evaluation), so
    # the mocked file must be a real readable stream, not nil — otherwise
    # zipline raises "Bad File/Stream" outside download_zipline's rescue.
    FileFile.expects(:new).at_least_once.returns(StringIO.new("dummy audio data"))
    post :search, params: { :q => a.speaker.last_name, :download => true }
    assert_response :success
    assert_equal 'application/zip',response.header['Content-Type']
  end
  
  test "search by full name assigns bio" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, params: { :q => a.speaker.full_name }
    assert_response :success
    assert assigns(:speaker), "No speaker was assigned"
  end
  
  test "search by place name assigns place bio" do
    p = FactoryGirl.create(:place, :bio => "The place is amazing")
    a = FactoryGirl.create(:audio_message, :place_id => p.id)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, params: { :q => a.place.name }
    assert_response :success
    assert assigns(:place), "No place was assigned"
  end

  test "search without param goes to home page" do
    get :search
    assert_response :redirect
  end

  test "search that returns nothing redirects to home page" do
    AudioMessage.expects(:search).returns([].paginate)
    get :search, params: { :q => 'xyzzy' }
    assert_response :redirect 
  end

  test "show a message without optional fields" do
    a = FactoryGirl.create(:audio_message, :event_date => nil, :place => nil)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, params: { :q => 'blah' }
    assert_response :success
  end
  
  test "show a message with optional fields" do
    a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns([a].paginate)
    get :search, params: { :q => 'blah' }
    assert_response :success
  end

  test "next button has query parameter with standard search" do
    a = []
    while a.size < 100
      a << FactoryGirl.create(:audio_message)
    end
    AudioMessage.expects(:search).returns(a.paginate)
    get :search, params: { :q => 'blah' }
    assert_response :success
    # assert_tag was removed from Rails; assert_select replaces it. The point
    # of this test is that the Next link carries the query param (q=blah)
    # along with the page, so pagination preserves the search.
    assert_select "a.next_page[rel=?]", "next" do |links|
      assert links.any? { |l| l["href"].include?("page=2") && l["href"].include?("q=blah") },
        "Next button should link to page 2 and preserve q=blah"
    end
  end

  test "search with fielded search string runs advanced conditions" do
    a = []
    while a.size < 10
      a << FactoryGirl.create(:audio_message)
    end
    AudioMessage.expects(:search).with(nil,has_key(:conditions)).returns(a.paginate)
    get :search, params: { :q => 'speaker:david' }
    assert_response :success
  end
  
  
  test "advance search redirects to stringified fielded query" do
    post :advanced_search, params: { :title => 'john',:speaker => "david" }
    assert_response :redirect
    assert_redirected_to "http://test.host/welcome/search?q=#{CGI::escape('speaker:david title:john')}"
  end

  test "favicon shortcut action" do
    get :favicon
    assert_response :redirect
  end

  test "get advanced search page" do
    get :advanced
    assert_response :success
  end

  test "request popout player for valid message" do
    a = FactoryGirl.create(:audio_message)
    get :player, params: { :id => a.id }
    assert_response :success
    assert_select 'title',/Audio Player/
    assert assigns(:media_url)
    assert assigns(:player_title)
  end

  test "sending bad page parameters triggers probe redirect" do
    get :index, params: { :page => "../../peterpan" }
    assert_redirected_to root_url
  end

end
