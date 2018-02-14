class CreateEventLocations < ActiveRecord::Migration
  def change
    create_table :event_locations do |t|
      t.integer :event_id, index: true
      t.string :street
      t.string :state
      t.string :city
      t.string :country, index: true
      t.string :zipcode
      t.decimal :latitude, :precision => 15, :scale => 10, :default => 0.0
      t.decimal :longitude, :precision => 15, :scale => 10, :default => 0.0
      t.timestamps null: false
    end
    # add_index :event_locations, :zipcode, :name => 'zipcode_index'
    add_index :event_locations, [:latitude, :longitude], :name => 'event_locations_coordinate_index'
  end
end
