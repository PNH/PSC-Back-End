class CreateLevelChecklists < ActiveRecord::Migration
  def change
    create_table :level_checklists do |t|
      t.integer :level_id
      t.string :title
      t.text :content
      t.integer :status

      t.timestamps null: false
    end
  end
end
