# frozen_string_literal: true
class Discipline < ActiveRecord::Base
  self.table_name = 'llcategories'

  acts_as_tree
  acts_as_paranoid

  enum kind: [:topic, :discipline]
  has_many :sub_disciplines, foreign_key: 'parent_id'
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  has_many :discipline_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'

  scope :disciplines, -> { where('parent_id IS NULL').discipline }

  validates :title, presence: true
end
