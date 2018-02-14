class UserConnection < ActiveRecord::Base

  belongs_to :user_requester, foreign_key: :user_one_id, class_name: 'User'
  belongs_to :user_requestee, foreign_key: :user_two_id, class_name: 'User'

  enum connection_status: {
    pending: 1,
    accepted: 2,
    declined: 3,
    blocked: 4,
    unknown: -1
  }

  validates :user_one_id, presence: true
  validates :user_two_id, presence: true

end
