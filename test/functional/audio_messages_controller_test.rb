require 'test_helper'

class AudioMessagesControllerTest < ActionController::TestCase
  
  test "get nonexistent file" do
    get :show, :id => -1
    assert_response :redirect
  end

  test "request for a hidden message does not return the file" do
    a = FactoryGirl.create(:audio_message, :publish => false)
    get :show, :id => a.id
    assert_response :redirect 
  end

  test "request for valid audio message returns data" do
    a = FactoryGirl.create(:audio_message, :filename => "TEST/test.mp3")
    FileUtils.mkdir_p("#{Rails.root.to_s}/public/audio/VFC-GOLD/TEST")
    f = File.open("#{Rails.root.to_s}/public/audio/VFC-GOLD/TEST/test.mp3","w")
    f.puts "this is the test data"
    f.close
    get :show, :id => a.id
    FileUtils.rm_rf("#{Rails.root.to_s}/public/audio/VFC-GOLD/TEST")
    assert_response :success
  end
  
  test "request for valid audio message but missing file redirects" do
    a = FactoryGirl.create(:audio_message, :filename => "TEST/invalid.mp3")
    get :show, :id => a.id
    assert_response :redirect
  end

  test "respond to an old style request for audio data" do
    s = FactoryGirl.create(:speaker, :last_name => "Jack", :first_name => "Jimmy", :middle_name => nil)
    a = FactoryGirl.create(:audio_message, :filename => "JackJimmy/MyOldStuff.mp3", :speaker => s)
    get :gold, :speaker_name => 'JackJimmy', :filename => 'MyOldStuff', :format => 'mp3'
    assert_response :redirect
    assert_redirected_to "/audio_messages/#{a.id}?dl=true"
  end
  
  test "respond to an old style request for missing audio data" do
    get :gold, :speaker_name => 'JackJimmy', :filename => 'MyReallyOldStuff', :format => 'mp3'
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "gold routing" do
    assert_routing "/VFC-GOLD/JackJimmy/MyOldStuff.mp3",
    {:controller => "audio_messages", :action => "gold",
      :speaker_name => "JackJimmy", :filename => "MyOldStuff", :format => "mp3" }
  end

  test "blocked host request for audio file" do
    Rails.cache.delete('blocked_hosts')
    b = FactoryGirl.create(:blocked_host)
    a = FactoryGirl.create(:audio_message)
    request.expects(:remote_ip).at_least_once.returns(b.ip_address)
    get :show, :id => a.id
    assert Rails.cache.read('blocked_hosts'), "blocked hosts should be cached"
    assert_redirected_to root_path
  end
  
end