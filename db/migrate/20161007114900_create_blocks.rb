class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :content_block, foreign_key: true
    end
  end
end
