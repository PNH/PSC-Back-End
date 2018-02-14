# frozen_string_literal: true
class TopicCategory < ActiveRecord::Base
  self.table_name = 'llcategories'

  acts_as_tree
  acts_as_paranoid

  enum kind: [:topic, :discipline, :entertainment, :level, :savvy]
  has_many :sub_topic_categories, foreign_key: 'parent_id'
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

  scope :topics, -> { where('parent_id IS NULL').topic }

  validates :title, presence: true
end
