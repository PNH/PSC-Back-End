# frozen_string_literal: true
class Entertainment < ActiveRecord::Base
  self.table_name = 'llcategories'

  acts_as_tree
  acts_as_paranoid

  enum kind: [:topic, :discipline, :entertainment]
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  has_many :entertainment_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'

  scope :entertainments, -> { where('parent_id IS NULL').entertainment }

  validates :title, presence: true
end
