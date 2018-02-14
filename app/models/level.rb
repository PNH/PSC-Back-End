class Level < ActiveRecord::Base
  acts_as_paranoid

  has_many :savvies, inverse_of: :level
  has_one :level_checklist

  validates :title, presence: true
end
