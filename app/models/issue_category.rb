class IssueCategory < ActiveRecord::Base
  acts_as_paranoid

  validates :title, presence: true

  belongs_to :goal
  has_many :issues, dependent: :destroy

  after_initialize do
    self.status = true if new_record?
  end
end
