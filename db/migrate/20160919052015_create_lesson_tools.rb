class CreateLessonTools < ActiveRecord::Migration
  def change
    create_table :lesson_tools do |t|
      t.string :title
      t.belongs_to :lesson, foreign_key: true
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.integer :position
    end
  end
end
