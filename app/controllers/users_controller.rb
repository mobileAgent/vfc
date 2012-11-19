class UsersController < ApplicationController

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
  
  def list
    @users = User.all
  end
  
  def edit
    @user = current_resource
  end

  def update
    @user = current_resource
    @user.admin = params[:user][:admin]
    @user.audio_message_editor = params[:user][:audio_message_editor]
    @user.speaker_editor = params[:user][:speaker_editor]
    @user.place_editor = params[:user][:place_editor]
    @user.video_editor = params[:user][:video_editor]
    @user.tags_editor = params[:user][:tags_editor]
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    if @user.save!
      flash[:notice] = "User record #{@user.id} updated"
      redirect_to :action => :list
    else
      flash[:notice] = "Update failed!"
      render :edit
    end
  end

  def delete
    @user = current_resource
    @user.delete
    flash[:notice] = "User record #{@user.id} deleted"
    redirect_to :action => :list
  end

  protected
  
  def current_resource
    if params[:id]
      @current_resource ||= User.find(params[:id])
    end
  end
  
end
