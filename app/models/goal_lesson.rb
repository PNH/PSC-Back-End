class GoalLesson < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :goal
  belongs_to :lesson

  validates :lesson, presence: true
end
