class CreateBlogPostComments < ActiveRecord::Migration
  def change
    create_table :blog_post_comments do |t|
      t.references :user, index: true, foreign_key: true
      t.belongs_to :blog_post, index: true, foreign_key: true
      t.string :comment
      t.integer :parent_id

      t.timestamps null: false
    end
    add_index :blog_post_comments, :parent_id
  end
end
