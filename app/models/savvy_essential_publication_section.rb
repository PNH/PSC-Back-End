class SavvyEssentialPublicationSection < ActiveRecord::Base
	belongs_to :savvy_essential_publication
	belongs_to :publication_section
	has_many :publication_attachments, dependent: :destroy

	acts_as_list scope: :savvy_essential_publication

	default_scope { order(position: :asc) }

	# validates :description, presence: true
	# :title, title removed
	validates_uniqueness_of :publication_section_id, scope: :savvy_essential_publication_id
	validates_presence_of :publication_section

	before_save :description_embedded_link_update
	def description_embedded_link_update
		return if description.nil?
		description.gsub!('<a href=', '<a target="_blank" href=')
	end
end
