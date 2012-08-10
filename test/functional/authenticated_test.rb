require 'test_helper'

class AuthenticatedTest < ActionController::TestCase
  
  protected
  
  def login(admin=false)
    @user = FactoryGirl.create(:user, :admin => admin)
    session[:user_id] = @user.id
    session[:user] = @user
  end
  
end
