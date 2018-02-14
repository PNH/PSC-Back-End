class DropXYColumnsFromAddresses < ActiveRecord::Migration
  def change
    # removels
    remove_column :addresses, :x_coordinate
    remove_column :addresses, :y_coordinate
    # additions
    add_column :addresses, :latitude, :decimal, :precision => 15, :scale => 10, :default => 0.0
    add_column :addresses, :longitude, :decimal, :precision => 15, :scale => 10, :default => 0.0
    # indexing
    add_index :addresses, [:latitude, :longitude], :name => 'addresses_coordinate_index'
  end
end
