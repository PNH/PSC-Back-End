class CreateGroupPosts < ActiveRecord::Migration
  def change
    create_table :group_posts do |t|
      t.references :user
      t.text :content
      t.integer :likes
      t.integer :status

      t.timestamps null: false
    end
  end
end
