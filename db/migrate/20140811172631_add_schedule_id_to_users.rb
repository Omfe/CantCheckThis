class AddScheduleIdToUsers < ActiveRecord::Migration
  def self.up
     add_column :users, :schedule_id, :integer
   end

   def self.down
     remove_column :users, :schedule_id
   end
end
