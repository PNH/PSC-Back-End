class CreateHorseLessons < ActiveRecord::Migration
  def change
    create_table :horse_lessons do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :horse, foreign_key: true
      t.belongs_to :lesson, foreign_key: true
      t.boolean :completed
      t.datetime :completed_time
      t.datetime :last_view
    end
  end
end
