class CreateForumResources < ActiveRecord::Migration
  def change
    create_table :forum_resources do |t|
      t.integer :rich_file_id
      t.references :resource, polymorphic: true, index: true
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.boolean :status
    end
    add_foreign_key :forum_resources, :rich_rich_files, column: :rich_file_id
    add_index :forum_resources, [:resource_id, :resource_type]
  end
end