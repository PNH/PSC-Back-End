class CreateWallPostComment < ActiveRecord::Migration
  def change
    create_table :wall_post_comments do |t|
      t.references :user, index: true, foreign_key: true
      t.belongs_to :wall, index: true, foreign_key: true
      t.string :comment
      t.integer :parent_id

      t.timestamps null: false
    end
    # add_index :wall_post_comments, :wall_id
    add_index :wall_post_comments, :parent_id
  end
end
