class MembershipDetail < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :membership_type
  belongs_to :billing_address, class_name: 'Address'

  after_save :sync_netsuite

  private

  def sync_netsuite
    # NetsuiteUpdateSubscriptionJob.perform_later(id)
  end
end
