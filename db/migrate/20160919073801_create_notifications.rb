class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :message
      t.belongs_to :user, foreign_key: true
      t.boolean :status
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
