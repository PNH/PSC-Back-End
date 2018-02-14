# frozen_string_literal: true
class SubInterest < Llcategory
  has_many :interest_resources, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'
end
