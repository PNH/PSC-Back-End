# frozen_string_literal: true
class Archive < Llcategory
  has_many :sub_archives, foreign_key: 'parent_id'

  scope :archives, -> { where('parent_id IS NULL').archive }
end
