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

  test "edit audio message" do
    login(false,true)
    @a = FactoryGirl.create(:audio_message)
    get :edit, :id => @a.id
    assert_response :success
    assert_not_nil assigns(:audio_message)
  end

  test "update audio message" do
    login(false,true)
    @a = FactoryGirl.create(:audio_message)
    @p = FactoryGirl.create(:place)
    @s = FactoryGirl.create(:speaker)
    @a.title = "A new title"
    @a.subj = "A new subj"
    @a.place_id = @p.id
    @a.speaker_id = @s.id
    post :update, :id => @a.id, :audio_message => @a.attributes
    assert_response :redirect
    assert_not_nil assigns(:audio_message)
    @newa = AudioMessage.find(@a.id)
    assert_equal "A new title",@newa.title
    assert_equal "A new subj", @newa.subj
    assert_equal @p.id, @newa.place_id
    assert_equal @s.id, @newa.speaker_id
  end
  
  test "update audio message protected attribute fails as editor" do
    login(false,true)
    @a = FactoryGirl.create(:audio_message)
    old_size = @a.filesize
    @a.filesize = old_size * 2
    post :update, :id => @a.id, :audio_message => @a.attributes
    assert_response :redirect
    assert_not_nil assigns(:audio_message)
    @newa = AudioMessage.find(@a.id)
    assert_equal old_size, @newa.filesize, "Update on protected attribute must fail"
  end
  
  test "update audio message protected attribute succeeds as admin" do
    login(true)
    @a = FactoryGirl.create(:audio_message)
    old_size = @a.filesize
    @a.filesize = old_size * 2
    post :update, :id => @a.id, :audio_message => @a.attributes
    assert_response :redirect
    assert_not_nil assigns(:audio_message)
    @newa = AudioMessage.find(@a.id)
    assert_equal @a.filesize, @newa.filesize,"Update on protected attribute must succeed"
  end

  test "delete audio message" do
    login(true)
    @a = FactoryGirl.create(:audio_message)
    post :delete, :id => @a.id
    assert_response :redirect
    assert_match /#{@a.full_title}/,flash[:notice]
  end
  
  protected
  
  def login(admin=false,editor=false)
    @user = FactoryGirl.create(:user, :admin => admin, :audio_message_editor => editor)
    session[:user_id] = @user.id
    session[:user] = @user
  end
  
end
