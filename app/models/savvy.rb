class Savvy < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :level, inverse_of: :savvies
  belongs_to :logo, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  has_many :lesson_categories

  validates :title, presence: true
end
