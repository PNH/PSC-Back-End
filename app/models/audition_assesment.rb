# frozen_string_literal: true
class AuditionAssesment < Llcategory
  has_many :sub_audition_assesments, foreign_key: 'parent_id'

  scope :auditions, -> { where('parent_id IS NULL').audition }
end
