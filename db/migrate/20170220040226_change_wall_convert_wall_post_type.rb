class ChangeWallConvertWallPostType < ActiveRecord::Migration
  def change
    remove_column :walls, :wall_post_type
    remove_column :walls, :wall_post_id
    add_column :walls, :wallposting_type, :string
    add_column :walls, :wallposting_id, :integer
  end
end
