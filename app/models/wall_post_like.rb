class WallPostLike < ActiveRecord::Base
  belongs_to :wall
  belongs_to :user
end
