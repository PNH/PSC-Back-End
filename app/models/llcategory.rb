# frozen_string_literal: true
class Llcategory < ActiveRecord::Base
  acts_as_tree
  acts_as_paranoid
  acts_as_list scope: [:parent_id]

  enum kind: [:level_savvy, :interest, :archive, :audition]
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

  validates :title, presence: true
end
