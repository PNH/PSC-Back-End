class CreateWallPostCommentAttachments < ActiveRecord::Migration
  def change
    create_table :wall_post_comment_attachments do |t|
      t.references :user, index: true, foreign_key: true
      t.references :wall, index: true, foreign_key: true
      # t.references :wall_post, index: true, foreign_key: true
      t.references :wall_post_comment, index: true, foreign_key: true
      t.integer :rich_file_id
    end
  end
end
