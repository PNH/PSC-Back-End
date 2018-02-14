class CreateForumPostAttachments < ActiveRecord::Migration
  def change
    create_table :forum_post_attachments do |t|
      t.references :forum_post, index: true, foreign_key: true
      t.integer :rich_file_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
