require 'test_helper'

class WritingsControllerTest < ActionController::TestCase

  test "should get writings list" do
    get :index
    assert_response :success
  end

  test "request for non-existent document redirects" do
    get :get, :name => "foo.pdf"
    assert_response :redirect
  end

  test "request for pdf document returns data" do
    FileUtils.mkdir_p(WRITINGS_PATH)
    f = File.open("#{WRITINGS_PATH}/bar.pdf","w")
    f.puts "test data"
    f.close
    get :get, :name => "bar.pdf"
    File.delete("#{WRITINGS_PATH}/bar.pdf")
    assert_response :success
  end

  test "request for html document renders view" do
    FileUtils.mkdir_p(WRITINGS_PATH)
    f = File.open("#{WRITINGS_PATH}/bar.html","w")
    f.puts "test data"
    f.close
    get :get, :name => "bar.html"
    File.delete("#{WRITINGS_PATH}/bar.html")
    assert_response :success
  end

end
