class AddNotificationTypeToNotification < ActiveRecord::Migration
  def change
    change_table :notifications do |t|
      t.integer :notification_type
    end
  end
end
