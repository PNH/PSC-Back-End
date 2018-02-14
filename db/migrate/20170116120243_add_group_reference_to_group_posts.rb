class AddGroupReferenceToGroupPosts < ActiveRecord::Migration
  def self.up
    add_column :group_posts, :group_id, :integer
  end
  def self.down
    remove_column :group_posts, :group_id
  end
end
