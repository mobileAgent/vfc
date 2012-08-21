class UserMailer < ActionMailer::Base

  default :from => 'webmaster@voicesforchrist.org'
  default :bcc => 'webmaster@voicesforchrist.org'

  def password(user,password)
    @user = user
    @password = password
    mail(:to => @user.email, :subject => t("user_mailer.password.subject"))
  end
  
end
