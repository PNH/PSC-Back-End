class CreateEventCategories < ActiveRecord::Migration
  def change
    create_table :event_categories do |t|
      t.integer :parent_id, index: true, default: 0
      t.string :title
      t.text :description
      t.boolean :status, default: true
      t.timestamps null: false
    end
  end
end
