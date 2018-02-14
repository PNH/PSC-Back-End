class BlogModerator < ActiveRecord::Base
  belongs_to :blog
  belongs_to :user

  enum moderator_type: [:moderator]

  validates :blog_id, presence: true
  validates :user_id, presence: true

  validates :user_id, uniqueness: true
end
