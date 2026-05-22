require 'digest/sha1'

class User < ActiveRecord::Base

  has_many :registrations

  # NOTE: :message is wrapped in a proc so the I18n lookup happens at
  # validation time, not at class-load time. Calling I18n.t directly here
  # runs during eager-load (before locale files are loaded in the test env),
  # which — combined with test_helper's raise-on-missing handler — aborts
  # the class definition. The :with option was a no-op on presence
  # validation (it never validated format) and has been removed.
  validates_presence_of   :email,
                          :message => proc { I18n.t("activerecord.errors.models.user.email_validation") }
                    

  attr_accessor :password_confirmation

  # attr_protected :admin

  validates_confirmation_of :password

  # Only require a password when creating a user. Updates that don't touch
  # the password (e.g. an admin toggling editor flags) must not be blocked
  # by this. Password changes go through update_password, where
  # validates_confirmation_of guards the new value.
  validate :password_check, :on => :create

  def password_check
    errors[:base] << I18n.t("activerecord.errors.models.user.password_validation") if password.blank?
  end

  def self.authenticate(email,password)
    user = self.find_by_email(email)
    if user
      expected_password = encrypted_password(password,user.salt)
      if user.hashed_password != expected_password
         user = nil
      end
    end
    user
  end

  # Virtual attribute
  def password
    @password
  end

  def password=(pwd)
     @password = pwd
     create_new_salt
     self.hashed_password = User.encrypted_password(self.password, self.salt)
  end


  def self.generate_password(length = 12)
     chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('1'..'9').to_a - ['o', 'O', 'i', 'I']
     Array.new(length) { chars[rand(chars.size)] }.join
  end

  private

  def self.encrypted_password(password,salt)
     string_to_hash = password + "bUcKiT" + salt
     Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
