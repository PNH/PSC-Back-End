class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :state
      t.string :city
      t.string :country
      t.string :zipcode
      t.string :x_coordinate
      t.string :y_coordinate
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
