# frozen_string_literal: true
class MembershipType < ActiveRecord::Base
  acts_as_paranoid

  has_many :item_costs
  has_many :currencies, through: :item_costs

  accepts_nested_attributes_for :item_costs, allow_destroy: true, reject_if:  proc { |attributes| attributes['cost'].blank? }

  enum billing_frequency: [:monthly, :annually]
  enum level: [:bronze, :silver, :gold, :employee, :instructor, :other]

  validates :billing_frequency, :level, :item_id, presence: true
  validate :prevent_currency_duplicate

  after_initialize do
    self.status = true if new_record?
  end

  def name
    "#{level.titleize} (#{billing_frequency.titleize}) Membership"
  end

  private

  def prevent_currency_duplicate
    ids = []
    item_costs.each do |ic|
      raise "Currency '#{ic.currency.title}' already in use" if ids.include?(ic.currency_id)
      ids << ic.currency_id
    end
  end
end
