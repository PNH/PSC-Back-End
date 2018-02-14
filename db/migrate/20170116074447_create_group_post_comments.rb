class CreateGroupPostComments < ActiveRecord::Migration
  def change
    create_table :group_post_comments do |t|
      t.references :user, index: true, foreign_key: true
      t.belongs_to :group_post, foreign_key: true
      t.string :comment
      t.integer :parent_id

      t.timestamps null: false
    end
    add_index :group_post_comments, :group_post_id
    add_index :group_post_comments, :parent_id
  end
end
