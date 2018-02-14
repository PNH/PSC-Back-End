class IndexBlogPostsSlugField < ActiveRecord::Migration
  def change
    add_index :blog_posts, :slug
  end
end
