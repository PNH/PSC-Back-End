class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.integer :kind
      t.text :data
      t.belongs_to :block, foreign_key: true
    end
  end
end
