require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < ActionMailer::TestCase

  def test_password_email
    user = FactoryGirl.build(:user)
    email = UserMailer.password(user,'foodebar').deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [user.email],email.to
    assert_equal ['webmaster@voicesforchrist.org'],email.from
    assert_equal "Your VFC password has been reset",email.subject
    assert_match /foodebar/,email.body.to_s
  end
  
end
