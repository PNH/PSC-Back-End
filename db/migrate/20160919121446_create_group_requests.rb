class CreateGroupRequests < ActiveRecord::Migration
  def change
    create_table :group_requests do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :group
      t.integer :type
      t.belongs_to :user, foreign_key: true
    end
  end
end
