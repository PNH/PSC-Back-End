class CreateBlogPost < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.references :user
      t.text :content
      t.integer :status
      t.integer :privacy
      t.belongs_to :blog, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
