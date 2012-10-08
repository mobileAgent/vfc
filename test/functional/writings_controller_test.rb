require 'test_helper'

class WritingsControllerTest < ActionController::TestCase

  test "should get writings list" do
    get :index
    assert_response :success
  end

  test "request for non-existent document redirects" do
    get :show, :id => 1111
    assert_response :redirect, "Redirect away from non-existent article"
  end
  
  test "request for writing with missing file redirects" do
    w = FactoryGirl.create(:writing)
    get :show, :id => w.id
    assert_response :redirect, "Redirect away from missing article"
    assert_not_nil assigns(:speaker), "Speaker should be assigned"
  end

  test "request for pdf document returns data" do
    w = FactoryGirl.create(:writing)
    FileUtils.mkdir_p(File.dirname("#{WRITINGS_PATH}/#{w.filename}"))
    f = File.open("#{WRITINGS_PATH}/#{w.filename}","w")
    f.puts "test data"
    f.close
    get :show, :id => w.id
    File.delete("#{WRITINGS_PATH}/#{w.filename}")
    assert_response :success
  end

  test "request for html document renders view" do
    w = FactoryGirl.create(:writing, :filename => "WRITINGS/foo.html")
    FileUtils.mkdir_p(File.dirname("#{WRITINGS_PATH}/#{w.filename}"))
    f = File.open("#{WRITINGS_PATH}/#{w.filename}","w")
    f.puts "test data"
    f.close
    get :show, :id => w.id
    File.delete("#{WRITINGS_PATH}/#{w.filename}")
    assert_response :success
  end

  test "request for writings by speaker shows list" do
    w = FactoryGirl.create(:writing)
    get :speaker, :id => w.speaker.id
    assert_response :success
    assert_not_nil assigns(:speaker), "Speaker should be assigned"
  end

end
