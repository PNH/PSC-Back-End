class AddPostingTypeAndIdToGroupPosts < ActiveRecord::Migration
  def change
    add_column :group_posts, :groupposting_type, :string
    add_column :group_posts, :groupposting_id, :integer
  end
end
