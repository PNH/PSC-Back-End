class WallPostAttachment < ActiveRecord::Base
  belongs_to :wall, class_name: 'Wall', foreign_key: 'wall_id'
  belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
end
