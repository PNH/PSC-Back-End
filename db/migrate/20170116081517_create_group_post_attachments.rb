class CreateGroupPostAttachments < ActiveRecord::Migration
  def change
    create_table :group_post_attachments do |t|
      t.references :group_post, index: true, foreign_key: true
      t.integer :rich_file_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
