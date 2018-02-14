class CreateChatBubbles < ActiveRecord::Migration
  def change
    create_table :chat_bubbles do |t|
      t.text :message
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.belongs_to :user, foreign_key: true
      t.belongs_to :lesson, foreign_key: true
    end
  end
end
