class CreateMessageRecipients < ActiveRecord::Migration
  def change
    create_table :message_recipients do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :message, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.boolean :status
    end
  end
end
