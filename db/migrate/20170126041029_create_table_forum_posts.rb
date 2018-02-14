class CreateTableForumPosts < ActiveRecord::Migration
  def change
    create_table :forum_posts do |t|
      t.references :user
      t.text :content
      t.integer :status
      t.belongs_to :forum, foreign_key: true
      t.timestamps null: false
    end
  end
end
