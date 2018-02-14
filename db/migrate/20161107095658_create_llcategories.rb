class CreateLlcategories < ActiveRecord::Migration
  def change
    create_table :llcategories do |t|
      t.integer :kind
      t.integer :parent_id
      t.string :title
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
