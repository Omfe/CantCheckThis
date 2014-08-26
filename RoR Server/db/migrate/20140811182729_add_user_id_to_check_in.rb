class AddUserIdToCheckIn < ActiveRecord::Migration
  def change
    add_column :check_ins, :user_id, :integer
  end
end
