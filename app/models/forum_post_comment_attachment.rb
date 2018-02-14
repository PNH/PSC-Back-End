class ForumPostCommentAttachment < ActiveRecord::Base
  belongs_to :forum_post
  belongs_to :forum_post_comment
  belongs_to :user
  belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
end
