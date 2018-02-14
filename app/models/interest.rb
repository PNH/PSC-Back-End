# frozen_string_literal: true
class Interest < Llcategory
  has_many :sub_interests, foreign_key: 'parent_id'

  scope :interests, -> { where('parent_id IS NULL').interest }
end
