class CreatePageAttachments < ActiveRecord::Migration
  def change
    create_table :page_attachments do |t|
      t.integer :page_id, index: true
      t.integer :rich_file_id
    end
  end
end
