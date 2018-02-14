class CreateContentBlocks < ActiveRecord::Migration
  def change
    create_table :content_blocks do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.string :title
      t.string :slug
    end
  end
end
