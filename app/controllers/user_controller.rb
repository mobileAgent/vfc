class UserController < ApplicationController

  def index
  end

  def new
    render :register
  end
    
  def register
    @user = User.new(params[:user])
    @user.last_visit = Time.now
    if request.post? and @user.save
      session[:user_id] = @user.id
      uri = session[:original_uri]
      redirect_to (uri || root_url), notice: t("login.created", :username => @user.name, :email => @user.email)
    end
  end
  
  def change_password
    @title = t("title.password_change")
  end
  
  def update_password
    user = User.find_by_id(session[:user_id])
    if user && user.update_attributes(params[:user])
      redirect_to root_url, notice: t("login.password_updated")
    else
      flash[:notice] = t(:update_failed)      
      redirect_to :action => "change_password"
    end
  end
  
end
