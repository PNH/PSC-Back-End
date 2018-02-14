class AddThumbnailAndSummaryToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :summary, :string
    add_column :blog_posts, :thumb_id, :integer
  end
end
