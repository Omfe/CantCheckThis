class User < ActiveRecord::Base
  belongs_to :schedule
  validates :first_name, :email, :password, :schedule_id, presence:true
  has_secure_password
  
  before_save { self.email = email.downcase }
 
  def generate_remember_token
    self.remember_token = SecureRandom.hex 
  end
  
end

