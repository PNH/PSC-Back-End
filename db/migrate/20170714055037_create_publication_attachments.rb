class CreatePublicationAttachments < ActiveRecord::Migration
  def up
    create_table :publication_attachments do |t|
      t.string :name
      t.integer :rich_file_id

      t.timestamps null: false
    end
  end

  def down
    drop_table :publication_attachments
  end
end
