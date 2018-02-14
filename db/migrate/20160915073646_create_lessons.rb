class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :title
      t.text :description
      t.text :objective
      t.string :slug
      t.integer :kind
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.belongs_to :lesson_category, foreign_key: true
      t.boolean :status
    end
  end
end
