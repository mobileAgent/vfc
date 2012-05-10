class UserController < ApplicationController

  before_filter :authorize, :only => [:change_password, :update_password]

   def add_user
      @user = User.new(params[:user])
      @user.last_visit = Time.now
      if request.post? and @user.save
         flash.now[:notice] = "Account created for #{@user.email}"
         session[:user_id] = @user.id
         uri = session[:original_uri]
         redirect_to(uri || {:controller => "welcome" , :action => "index"})
      end
   end

   def change_password
      @title = 'Change Password'
   end

   def update_password
      user = User.find_by_id(session[:user_id])
      if user && user.update_attributes(params[:user])
         flash[:notice] = 'Password updated'
         redirect_to :controller => "welcome" , :action => "index"
      else
         flash[:notice] = 'Update failed'
         redirect_to :action => "change_password"
      end
   end
end
