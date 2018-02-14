class RemoveLikesColumnFromGroupPost < ActiveRecord::Migration
  def self.up
    remove_column :group_posts, :likes
  end
  def self.down
    add_column :group_posts, :likes, :integer
  end
end
