class AddCommentCounterToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :comment_count, :integer, default: 0
  end
end
