require 'test_helper'

class UserControllerTest < ActionController::TestCase
  
  def setup
    @user = FactoryGirl.create(:user)
    session[:user_id] = @user.id
  end

  test "get password change screen" do
    get :change_password
    assert_response :success
  end
  
  test "access protected action without login must fail" do
    session[:user_id] = nil
    get :change_password
    assert_redirected_to root_url
  end

  test "change of password saved through" do
    post :update_password, :user => {:password => "newpass", :password_confirmation => "newpass" }
    assert_redirected_to root_url
    assert User.authenticate @user.email, "newpass"
  end

  test "change of password not saved with bad confirmation" do
    post :update_password, :user => {:password => "newpass", :password_confirmation => "badpass" }
    assert_response :redirect
    assert User.authenticate @user.email, "secret"
  end


  test "user account creation page returned on get" do
    get :register
    assert_response :success
  end

  test "user account created on page post" do
    assert_difference('User.count') do
      post :register, :user => FactoryGirl.attributes_for(:user)
    end
  end
  
end
