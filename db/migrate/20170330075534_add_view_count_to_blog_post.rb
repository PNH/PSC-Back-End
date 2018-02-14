class AddViewCountToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :views, :integer, :default => 0
  end
end
