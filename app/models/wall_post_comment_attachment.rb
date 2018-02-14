class WallPostCommentAttachment < ActiveRecord::Base
  belongs_to :wall
  # belongs_to :wall_post
  belongs_to :wall_post_comment
  belongs_to :user
  belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
end
