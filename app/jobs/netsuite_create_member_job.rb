class NetsuiteCreateMemberJob < ActiveJob::Base
  queue_as :default

  def perform(user, credit_card, password_text, referralId, referralCode)
    pcn_event = ''
    preview_membership = 'T'
    item_id = user.membership_details.last.membership_type.item_id.to_s
    Netsuite::ParelliApi.create_membership(user, item_id, user.billing_address,
                                           credit_card, referralId,
                                           pcn_event, preview_membership,
                                           referralCode, password_text)
  end
end
