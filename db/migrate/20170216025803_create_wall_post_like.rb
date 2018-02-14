class CreateWallPostLike < ActiveRecord::Migration
  def change
    create_table :wall_post_likes do |t|
      t.belongs_to :wall, index: true, foreign_key: true
      t.references :user
      t.integer :status

      t.timestamps null: false
    end
  end
end
