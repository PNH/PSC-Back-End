# frozen_string_literal: true
class SubLevelAndSavvy < Llcategory
  has_many :level_and_savvy_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'
end
