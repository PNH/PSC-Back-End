class PlaylistResourceFix < ActiveRecord::Migration
  def change
    remove_foreign_key :playlist_resources, :lesson_resource
    remove_column :playlist_resources, :lesson_resource_id
    change_table :playlist_resources do |t|
      t.belongs_to :learnging_library, foreign_key: true
    end
  end
end
