class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.string :title
      t.string :short_description
      t.text :description
      t.integer :privacy
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.belongs_to :topic, foreign_key: true
    end
  end
end
