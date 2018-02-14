class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :address
  belongs_to :subscrpt_credit_card
end
