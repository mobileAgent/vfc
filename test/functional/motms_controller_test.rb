require 'test_helper'

class MotmsControllerTest < ActionController::TestCase

  test "should get list" do
    l = Language.default.first || FactoryGirl.create(:language)
    Rails.cache.delete("motm-#{l.cc}")
    (1..10).each do |n|
      a = FactoryGirl.create(:audio_message, :language => l)
      FactoryGirl.create(:motm, :audio_message => a)
    end
    get :index
    assert_response :success
    assert_not_nil assigns(:motms),"List of motms should be assigned"
    assert assigns(:motms).size > 0,"list of assigned motms should be > 0 for locale #{assigns(:locale)}"
    assert Rails.cache.read("motm-#{l.cc}"),"Motm should be cached by language/locale #{assigns(:locale)}"
  end

end
