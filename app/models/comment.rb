class Comment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  scope :recent_comments, -> (limit) { where(status: true).order(created_at: :desc).first(limit) }
end
