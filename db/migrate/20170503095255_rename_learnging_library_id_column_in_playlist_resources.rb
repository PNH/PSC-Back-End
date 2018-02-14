class RenameLearngingLibraryIdColumnInPlaylistResources < ActiveRecord::Migration
  def change
    # rename_column :playlist_resources, :learnging_library_id, :file_id
    add_column :playlist_resources, :file_id, :integer
    add_column :playlist_resources, :title, :string
  end
end
