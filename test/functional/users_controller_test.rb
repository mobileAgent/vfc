require 'test_helper'

class UsersControllerTest < AuthenticatedTest
  
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
    assert_redirected_to root_url,"Should be redirected to root url on save"
    assert User.authenticate(@user.email,"newpass"),"User password should have been saved"
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

  test "list users as admin" do
    login(true)
    get :list
    assert_response :success
  end

  test "edit and update user" do
    login(true)
    u = FactoryGirl.create(:user, :video_editor => false)
    get :edit, :id => u.id
    assert_response :success
    u.video_editor = true
    post :update, :id => u.id, :user => u.attributes
    v = User.find(u.id)
    assert v.video_editor,"Video editor should be set to true after update"
  end

  test "delete user" do
    login(true)
    u = FactoryGirl.create(:user)
    assert_difference('User.count',-1) do
      post :delete, :id => u.id
    end
  end
  
end
