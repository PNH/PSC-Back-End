# frozen_string_literal: true
class LevelAndSavvy < Llcategory
  has_many :sub_level_and_savvies, foreign_key: 'parent_id'

  scope :level_savvies, -> { where('parent_id IS NULL').level_savvy }
end
