# frozen_string_literal: true
class SubAuditionAssesment < Llcategory
  has_many :audition_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'
end
