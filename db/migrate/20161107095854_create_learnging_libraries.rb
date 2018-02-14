# frozen_string_literal: true
class CreateLearngingLibraries < ActiveRecord::Migration
  def change
    create_table :learnging_libraries do |t|
      t.integer :file_id
      t.integer :thumb_id
      t.timestamps null: false
      t.belongs_to :llcategory, foreign_key: true
      t.boolean :featured
      t.string :title
      t.integer :file_type
      t.boolean :status
    end
    add_foreign_key :learnging_libraries, :rich_rich_files, column: :file_id
    add_foreign_key :learnging_libraries, :rich_rich_files, column: :thumb_id
  end
end
