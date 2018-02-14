class CreateEventCategoryMappings < ActiveRecord::Migration
  def change
    create_table :event_category_mappings do |t|
      t.integer :event_id, index: true
      t.integer :event_category_id
      t.timestamps null: false
    end
  end
end
