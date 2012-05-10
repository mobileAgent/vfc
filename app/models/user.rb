require 'digest/sha1'

class User < ActiveRecord::Base

  has_many :registrations

  validates_presence_of   :email,
                          :with => /\A[-A-Za-z0-9_\.]+@[-A-Za-z_0-9\.]+\.[A-Za-z]{2,6}\Z/,
                          :message => "is missing or invalid"

#  validates_uniqueness_of :email,
#                          :on => :create,
#                          :message => "is already being used"

  attr_accessor :password_confirmation

  attr_protected :admin

  validates_confirmation_of :password

  validate :password_check

  def password_check
    errors[:base] << "Missing password" if password.blank?
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
