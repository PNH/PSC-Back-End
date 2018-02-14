class SubscrptCreditCard < ActiveRecord::Base
  belongs_to :user
  has_many :subscriptions, dependent: :destroy
  attr_accessor :expiry_month, :expiry_year, :cvs_code, :administrative_division
  # attr_accessor :expiry_month, :expiry_year, :cvs_code, :zipcode, :administrative_division, :cc_type, :number, :expire_date
end
