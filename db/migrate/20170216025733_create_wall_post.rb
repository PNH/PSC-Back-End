class CreateWallPost < ActiveRecord::Migration
  def change
    create_table :wall_posts do |t|
      t.references :user
      t.text :content
      t.integer :status
      t.belongs_to :wall, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
