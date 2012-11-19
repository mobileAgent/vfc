class LoginController < ApplicationController

  def index
     redirect_to :action => 'login'
  end

  def login
    @title = t("title.login")
    session[:user_id] = session[:user] = nil
    if request.post?
      user = User.authenticate(params[:email], params[:password])
       if user
         uri = session[:original_uri]
         #request.reset_session    # create a new session to stop fixation
         #session = request.session # overwrite the current session
         session[:original_uri] = nil
         session[:user_id] = user.id
         session[:user] = user
         user.update_attributes(:last_visit => DateTime.now)
         if user.admin?
           flash[:notice] = t("login.admin", :user => user.name)
         else
           flash[:notice] = t("login.user", :user => user.name)
         end
         redirect_to root_url and return
       else
         flash[:notice] = t("login.fail")
       end
    else
      session[:original_uri] = nil
    end
  end
  
  def logout
    session[:user_id] = nil
    redirect_to root_url and return
  end

  def forgotten_password
  end

  def reset_password
     if request.post?
        user = User.find_by_email(params[:email])
        if user
           new_password = User.generate_password
           user.password = new_password
           user.save
           UserMailer.password(user, new_password).deliver
           flash[:notice] = t("login.reset", :email => params[:email])
        else
           flash[:notice] = t("login.fail")
        end
     end
     redirect_to :controller => 'login', :action => 'login' and return
  end

end
