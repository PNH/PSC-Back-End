class PublicationAttachment < ActiveRecord::Base
	belongs_to :savvy_essential_publication_section
	belongs_to :resource, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

	validates :name, presence: true
	validates_presence_of :resource
end
