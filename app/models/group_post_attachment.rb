class GroupPostAttachment < ActiveRecord::Base
  belongs_to :group_post
  belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
end
