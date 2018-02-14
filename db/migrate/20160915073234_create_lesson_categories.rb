class CreateLessonCategories < ActiveRecord::Migration
  def change
    create_table :lesson_categories do |t|
      t.string :title
      t.integer :badge_icon_id
      t.string :badge_title
      t.text :description
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.belongs_to :savvy, foreign_key: true
    end
    add_foreign_key :lesson_categories, :rich_rich_files, column: :badge_icon_id
  end
end
