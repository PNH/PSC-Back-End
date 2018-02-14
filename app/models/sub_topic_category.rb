# frozen_string_literal: true
class SubTopicCategory < ActiveRecord::Base
  self.table_name = 'llcategories'
  acts_as_paranoid
  enum kind: [:topic, :discipline]

  belongs_to :topic_category, class_name: 'TopicCategory', foreign_key: 'parent_id'
  has_many :topic_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

  validates :title, presence: true
end
