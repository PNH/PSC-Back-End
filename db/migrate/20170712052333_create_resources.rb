class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :kind
      t.integer :rich_file_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
