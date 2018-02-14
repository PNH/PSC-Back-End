class ItemCost < ActiveRecord::Base
  belongs_to :currency
  belongs_to :membership_type

  validates :currency, :cost, presence: true
end
