class BlogPostAttachment < ActiveRecord::Base
  belongs_to :blog_post
  belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
end
