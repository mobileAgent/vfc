require 'test_helper'

class DatesControllerTest < ActionController::TestCase

  test "should get dates list" do
    get :index
    assert_response :success
  end

  test "should get dates by order added to site" do
    get :years
    assert_response :success
  end

  test "should get messages for the specified year" do
    get :year, :id => 1986
    assert_response :success
  end

  test "should get messages by speaker added on the specified yyyy-mm" do
    @a = FactoryGirl.create(:audio_message, :created_at => "1986-02-03")
    get :speaker, :speaker_id => @a.speaker_id, :date => '1986-02'
    assert_response :success
  end
  
  test "should get messages  added on the specified yyyy-mm" do
    @a = FactoryGirl.create(:audio_message, :created_at => "1986-02-03")
    get :show, :id => '1986-02'
    assert_response :success
  end

  test "show messages preached by a speaker in the specified year" do
    @a = FactoryGirl.create(:audio_message, :event_date => "1986-02-03")
    get :delivered, :id => 1986, :speaker_id => @a.speaker_id
    assert_response :success
  end

end
