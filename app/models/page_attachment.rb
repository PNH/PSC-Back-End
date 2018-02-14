class PageAttachment < ActiveRecord::Base
  belongs_to :page
  belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

  validates :title, presence: true
  validates :rich_file_id, presence: true
end
