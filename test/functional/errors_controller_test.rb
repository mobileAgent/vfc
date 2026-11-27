require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase

  test "not found page says 404" do
    get :not_found
    assert_response :not_found
    assert_equal 'text/html', response.media_type
  end

  test "not found page for another format is still an HTML 404" do
    get :not_found, format: :json
    assert_response :not_found
    assert_equal 'text/html', response.media_type
  end

  test "error page says 500" do
    get :error
    assert_response :internal_server_error
  end

end
