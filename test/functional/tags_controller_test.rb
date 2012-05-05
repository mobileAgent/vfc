require 'test_helper'
require 'will_paginate/array'

class TagsControllerTest < ActionController::TestCase

  test "should get items for tag" do
    a = FactoryGirl.create(:audio_message)
    a.tag_list << 'Bible'
    a.save!
    AudioMessage.expects(:search).returns([a].paginate)
    get :show, :id => 'Bible'
    assert_response :success
    assert assigns :items
  end

end
