class PublicationSection < ActiveRecord::Base
  has_many :savvy_essential_publication_sections, dependent: :destroy

  validates :title, presence: true
end
