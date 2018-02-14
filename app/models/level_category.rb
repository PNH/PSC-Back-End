# frozen_string_literal: true
class LevelCategory < ActiveRecord::Base
  self.table_name = 'llcategories'

  acts_as_tree
  acts_as_paranoid

  enum kind: [:topic, :discipline, :entertainment, :level, :savvy]
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  has_many :level_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'

  scope :levels, -> { where('parent_id IS NULL').level }

  validates :title, presence: true
end
