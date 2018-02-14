class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :message
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :user, foreign_key: true
      t.integer :type
      t.boolean :status
      t.integer :privacy
      t.text :content
    end
  end
end
