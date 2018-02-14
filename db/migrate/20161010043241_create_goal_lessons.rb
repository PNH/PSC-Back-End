class CreateGoalLessons < ActiveRecord::Migration
  def change
    create_table :goal_lessons do |t|
      t.belongs_to :goal, foreign_key: true
      t.belongs_to :lesson, foreign_key: true
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
