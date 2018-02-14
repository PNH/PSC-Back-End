class CreateWall < ActiveRecord::Migration
  def change
    create_table :walls do |t|
      t.references :user
      t.integer :author_id
      t.integer :wall_post_id, index: true
      t.integer :status
      t.integer :privacy
      t.integer :wall_post_type
      t.timestamps null: false
    end
  end
end
