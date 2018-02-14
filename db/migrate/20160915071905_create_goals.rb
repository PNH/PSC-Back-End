class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :title
      t.boolean :status
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.integer :rich_file_id
    end
    add_foreign_key :goals, :rich_rich_files, column: :rich_file_id
  end
end
