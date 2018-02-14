class PlaylistResource < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :file, class_name: 'Rich::RichFile', foreign_key: 'file_id'
  # belongs_to :lesson_resource, class_name: 'LearngingLibrary', foreign_key: 'learnging_library_id'
end
