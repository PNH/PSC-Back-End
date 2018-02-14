class WallSolutionmapPost < ActiveRecord::Base
  has_one :wall, as: :wallposting
  belongs_to :horse
  belongs_to :poster, class_name: 'Rich::RichFile', foreign_key: 'solutionmap_id'
end
