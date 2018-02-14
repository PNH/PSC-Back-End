class CreateBlogPostAttachments < ActiveRecord::Migration
  def change
    create_table :blog_post_attachments do |t|
      t.belongs_to :blog_post, index: true, foreign_key: true
      t.integer :rich_file_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
