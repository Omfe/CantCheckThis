class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.time :check_in
      t.time :check_out

      t.timestamps
    end
  end
end
