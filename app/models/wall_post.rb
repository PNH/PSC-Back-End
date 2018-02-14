class WallPost < ActiveRecord::Base
  has_one :wall, as: :wallposting
end
