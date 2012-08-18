require 'test_helper'
require 'will_paginate/array'

class LanguagesControllerTest < ActionController::TestCase

  def setup
    @speaker = FactoryGirl.create(:speaker, :last_name => "Jack", :first_name => "Jimmy", :middle_name => nil);
    @collection = []
    10.times { |i| @collection << FactoryGirl.create(:audio_message, :speaker => @speaker) }
    @paginated_collection = @collection.paginate
  end
  
  test "should get language list" do
    get :index
    assert_response :success
    assert_not_nil assigns(:languages)
  end

  test "should get list of messages by language" do
    @a = FactoryGirl.create(:audio_message)
    AudioMessage.expects(:search).returns(@paginated_collection)
    get :show, :id => @a.language_id
    assert_response :success
  end

  test "should get list of speakers for a language" do
    @a = FactoryGirl.create(:audio_message)
    get :speakers, :id => @a.language_id
    assert_response :success
  end

  test "should get locale language first" do
    @fr = FactoryGirl.create(:language, :name => "French", :cc => "fr")
    @a = FactoryGirl.create(:audio_message, :language => @fr)
    get :index, :locale => :fr
    assert_response :success
    assert_not_nil assigns(:languages)
    assert assigns(:languages).first.cc == @fr.cc
  end

end
