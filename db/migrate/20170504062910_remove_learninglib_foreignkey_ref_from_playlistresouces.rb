class RemoveLearninglibForeignkeyRefFromPlaylistresouces < ActiveRecord::Migration
  def change
    playlist_resources = PlaylistResource.all
    playlist_resources.each do |presource|
      lresource = LearngingLibrary.find_by id: presource.learnging_library_id
      if !presource.nil?
        presource.title = lresource.title
        presource.file_id = lresource.file_id
        presource.save!
      end
    end
    remove_reference :playlist_resources, :learnging_library, index: true, foreign_key: true
  end
end
