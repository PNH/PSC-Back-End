# frozen_string_literal: true
class SubArchive < Llcategory
  has_many :archive_resources,-> { order(:position) }, class_name: 'LearngingLibrary', foreign_key: 'llcategory_id'
end
