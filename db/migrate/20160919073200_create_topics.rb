class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title
      t.text :description
      t.boolean :status
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
