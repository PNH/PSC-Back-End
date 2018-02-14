class Issue < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :savvy
  belongs_to :issue_category

  validates :title, :savvy, presence: true
end
