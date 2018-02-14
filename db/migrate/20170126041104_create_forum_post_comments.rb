class CreateForumPostComments < ActiveRecord::Migration
  def change
    create_table :forum_post_comments do |t|
      t.references :user, index: true, foreign_key: true
      t.belongs_to :forum_post, foreign_key: true
      t.string :comment
      t.integer :parent_id

      t.timestamps null: false
    end
    add_index :forum_post_comments, :forum_post_id
    add_index :forum_post_comments, :parent_id
  end
end
