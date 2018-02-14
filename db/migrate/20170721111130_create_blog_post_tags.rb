class CreateBlogPostTags < ActiveRecord::Migration
  def change
    create_table :blog_post_tags do |t|
			t.belongs_to :blog_post, foreign_key: true
			t.belongs_to :tag, foreign_key: true
      t.timestamps null: false
    end
  end
end
