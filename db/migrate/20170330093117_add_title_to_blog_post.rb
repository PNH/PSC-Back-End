class AddTitleToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :title, :string
  end
end
