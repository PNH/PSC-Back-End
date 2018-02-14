class CreateUserConnections < ActiveRecord::Migration
  def change
    create_table :user_connections do |t|
      t.integer :user_one_id, index: true
      t.integer :user_two_id, index: true
      t.integer :connection_status
      t.integer :action_user_id
      t.timestamps null: false
    end
    add_index :user_connections, [:user_one_id, :user_two_id], :unique => true
  end
end
