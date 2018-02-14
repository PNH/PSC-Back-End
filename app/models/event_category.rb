class EventCategory < ActiveRecord::Base
  # extend ActiveSupport::Concern

  has_many :event_categories,  foreign_key: :parent_id, class_name: 'EventCategory', :dependent => :destroy
  belongs_to :event_category,  foreign_key: :parent_id, class_name: 'EventCategory'

  accepts_nested_attributes_for :event_categories, :allow_destroy => true

  # def self.parents_only
  #   where(parent_id: nil)
  # end
  validates :title, presence: true

  scope :parents_only, -> { where(parent_id: nil) }

  validate :has_parent_category
  def has_parent_category
    if self.event_category.nil?
      errors.add("Sub-Category", "- should have a parent category")
    end
  end

end
