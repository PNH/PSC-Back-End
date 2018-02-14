class MakeLessonsSortable < ActiveRecord::Migration
  def change
    change_table :lessons do |t|
      t.integer :position
    end
    change_table :lesson_categories do |t|
      t.integer :position
    end
  end
end
