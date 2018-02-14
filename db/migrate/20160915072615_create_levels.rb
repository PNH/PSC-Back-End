class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.string :title
      t.string :color
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
