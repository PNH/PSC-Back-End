class CreateForumTopic < ActiveRecord::Migration
  def change
    create_table :forum_topics do |t|
      t.integer :parent_id
      t.string :title
      t.text :description
      t.integer :privacy      
      t.boolean :status
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.integer :position
      t.belongs_to :user, foreign_key: true
    end
  end
end
