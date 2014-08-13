class User < ActiveRecord::Base
  belongs_to :schedule
  validates :first_name, :email, :password, :schedule_id, presence:true
end

