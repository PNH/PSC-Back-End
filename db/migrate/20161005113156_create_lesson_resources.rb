class CreateLessonResources < ActiveRecord::Migration
  def change
    create_table :lesson_resources do |t|
      t.belongs_to :lesson, foreign_key: true
      t.integer :rich_file_id
      t.integer :kind
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.integer :position
    end
    add_foreign_key :lesson_resources, :rich_rich_files, column: :rich_file_id
  end
end
