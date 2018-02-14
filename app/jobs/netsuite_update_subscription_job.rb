class NetsuiteUpdateSubscriptionJob < ActiveJob::Base
  queue_as :default

  def perform(membership_detail_id)
    md = MembershipDetail.find(membership_detail_id)
    subscription = md.user.subscriptions.last
    Netsuite::ParelliApi.updateSubscription(subscription.external_id,
                                            custrecord_pnh_subscrpt_id: subscription.external_id,
                                            custrecord_pnh_subscrpt_auto_renewal: subscription.is_auto_renewal)
  end
end
