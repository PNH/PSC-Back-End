class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :short_description
      t.text :description
      t.boolean :status
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
