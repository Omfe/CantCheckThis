require 'bcrypt'

class User < ActiveRecord::Base
  belongs_to :schedule
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :first_name, :password, :schedule_id, presence:true
  validates :email, presence:true, format: { with: EMAIL_REGEX }, uniqueness: true
  include BCrypt
  
  before_save { self.email = email.downcase }
 
  def generate_remember_token
    self.remember_token = SecureRandom.hex 
  end
  
  def password
    @password ||= Password.new(encrypted_password)
  end
  
  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
  end
  
end

