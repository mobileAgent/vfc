require 'test_helper'

class VideosControllerTest < ActionController::TestCase

  test "should get videos list" do
    get :index
    assert_response :success
  end

  test "request for non-existent video redirects" do
    get :show, :id => 1111
    assert_response :redirect, "Redirect away from non-existent video"
  end

  test "request for video with missing file redirects" do
    v = FactoryGirl.create(:video)
    get :show, :id => v.id
    assert_response :redirect, "Redirect away from video with mising file"
    assert_not_nil assigns(@speaker), "Set speaker for video listing"
  end

  test "request for video file renders bytes" do
    v = FactoryGirl.create(:video, :filename => "SPEAKER/foo.mp4")
    FileUtils.mkdir_p(File.dirname("#{VIDEO_PATH}/#{v.filename}"))
    f = File.open("#{VIDEO_PATH}/#{v.filename}","w")
    f.puts "test data"
    f.close
    get :show, :id => v.id
    File.delete("#{VIDEO_PATH}/#{v.filename}")
    assert_response :success
  end

  test "request for video by speaker shows list" do
    v = FactoryGirl.create(:video)
    get :speaker, :id => v.speaker.id
    assert_response :success
    assert_not_nil assigns(@speaker), "Set speaker for video listing"
  end

end
