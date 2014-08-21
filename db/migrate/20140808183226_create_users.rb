class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.integer :points
      t.boolean :is_admin

      t.timestamps
    end
  end
end
