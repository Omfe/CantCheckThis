require 'bcrypt'

class User < ActiveRecord::Base
  belongs_to :schedule
  validates :first_name, :email, :password, :schedule_id, presence:true
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

