# frozen_string_literal: true
class SavvyCategory < ActiveRecord::Base
  self.table_name = 'llcategories'

  acts_as_tree
  acts_as_paranoid

  enum kind: [:topic, :discipline, :entertainment, :level, :savvy]
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  has_many :savvy_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'

  scope :savvies, -> { where('parent_id IS NULL').savvy }

  validates :title, presence: true
end
