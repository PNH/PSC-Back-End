class Resource < ActiveRecord::Base
  belongs_to :user
  belongs_to :file, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

  enum kind: [:walls, :forums, :blogs, :groups, :events, :comments, :others]
  enum statu: [:enabled, :disabled]

end
