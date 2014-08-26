class CreateCheckIns < ActiveRecord::Migration
  def change
    create_table :check_ins do |t|
      t.datetime :checked_in_at

      t.timestamps
    end
  end
end
