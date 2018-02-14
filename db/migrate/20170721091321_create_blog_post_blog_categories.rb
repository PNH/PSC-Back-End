class CreateBlogPostBlogCategories < ActiveRecord::Migration
  def up
    create_table :blog_post_blog_categories do |t|
      t.belongs_to :blog_post, foreign_key: true
      t.belongs_to :blog_category, foreign_key: true
      t.timestamps null: false
    end
  end

  def down
    drop_table :blog_post_blog_categories
  end
end
