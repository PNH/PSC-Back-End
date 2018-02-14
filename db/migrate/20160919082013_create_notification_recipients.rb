class CreateNotificationRecipients < ActiveRecord::Migration
  def change
    create_table :notification_recipients do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :notification, foreign_key: true
      t.belongs_to :user, foreign_key: true
    end
  end
end
