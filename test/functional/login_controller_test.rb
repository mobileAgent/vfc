require 'test_helper'

class LoginControllerTest < ActionController::TestCase

  test "login with wrong password must fail" do
    @user = FactoryGirl.create(:user)
    post :login, :email => @user.email, :password => 'xyzzy'
    assert_response :success
    assert_match /.*does not match.*/,flash[:notice]
    assert_nil session[:user_id]
  end
  
  test "login with correct password" do
    @user = FactoryGirl.create(:user)
    post :login, :email => @user.email, :password => 'secret'
    assert_response :redirect
    assert_match /Hi, #{@user.email}.*/,flash[:notice]
    assert_equal session[:user_id],@user.id
  end

  test "reset password action generates email and saves new password" do
    @user = FactoryGirl.create(:user)
    @old_password = @user.password
    post :reset_password, :email => @user.email
    assert !ActionMailer::Base.deliveries.empty?
    @user = User.find(@user.id)
    assert @old_password != @user.password
  end
  
  test "reset password on bogus email fails" do
    post :reset_password, :email => "xyzzy@example.com"
    assert_match /.*does not match.*/,flash[:notice]
  end
  
  test "logout clears session" do
    @user = FactoryGirl.create(:user)
    session[:user_id] = @user.id #  login
    get :logout
    assert_nil session[:user_id]
  end

  test "forgotten password page" do
    get :forgotten_password
    assert_select 'title',/Forgotten Password/
  end

  test "login as admin user" do
    @user = FactoryGirl.create(:user, :admin => true)
    post :login, :email => @user.email, :password => 'secret'
    assert_match /Kenichiwa, #{@user.email}.*/,flash[:notice]
    assert_equal session[:user_id],@user.id
  end

  
end
