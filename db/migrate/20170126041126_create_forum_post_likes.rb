class CreateForumPostLikes < ActiveRecord::Migration
  def change
    create_table :forum_post_likes do |t|
      t.references :forum, foreign_key: true
      t.belongs_to :forum_post, index: true, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :status

      t.timestamps null: false
    end
  end
end
