class CreateGroupPostLikes < ActiveRecord::Migration
  def change
    create_table :group_post_likes do |t|
      t.references :group, foreign_key: true
      t.belongs_to :group_post, index: true, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :status

      t.timestamps null: false
    end
  end
end
