class CreateWallPostAttachment < ActiveRecord::Migration
  def change
    create_table :wall_post_attachments do |t|
      t.belongs_to :wall, index: true, foreign_key: true
      t.integer :rich_file_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
