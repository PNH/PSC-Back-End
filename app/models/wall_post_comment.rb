class WallPostComment < ActiveRecord::Base
  belongs_to :wall
  belongs_to :user
  has_many :wall_post_comment_attachments, :dependent => :destroy
end
