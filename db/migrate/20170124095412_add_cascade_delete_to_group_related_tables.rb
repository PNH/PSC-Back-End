class AddCascadeDeleteToGroupRelatedTables < ActiveRecord::Migration
  def self.up
    remove_foreign_key :group_members, :groups
    remove_foreign_key :group_moderators, :groups
    remove_foreign_key :group_post_comments, :group_posts
    remove_foreign_key :group_post_attachments, :group_posts
  end

  def self.down
    add_foreign_key :group_members, :groups
    add_foreign_key :group_moderators, :groups
    add_foreign_key :group_post_comments, :group_posts
    add_foreign_key :group_post_attachments, :group_posts
  end
end
