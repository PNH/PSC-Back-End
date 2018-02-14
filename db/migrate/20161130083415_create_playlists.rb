class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :title
      t.belongs_to :user, foreign_key: true
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
