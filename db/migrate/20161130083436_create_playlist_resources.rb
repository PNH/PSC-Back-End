class CreatePlaylistResources < ActiveRecord::Migration
  def change
    create_table :playlist_resources do |t|
      t.belongs_to :lesson_resource, foreign_key: true
      t.belongs_to :playlist, foreign_key: true
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
