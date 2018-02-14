class CreateEventPricings < ActiveRecord::Migration
  def change
    create_table :event_pricings do |t|
      t.integer :event_id, index: true
      t.string :title
      t.string :description
      t.string :price
      t.timestamps null: false
    end
  end
end
