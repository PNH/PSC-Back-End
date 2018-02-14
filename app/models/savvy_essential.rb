class SavvyEssential < ActiveRecord::Base
	has_many :savvy_essential_publications, dependent: :destroy
	validates :title, presence: true
end
