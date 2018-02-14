class NetsuiteChangeCreditCardJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, cards_params)
    user = User.find(user_id)
    card = SubscrptCreditCard.new(cards_params)
    Netsuite::ParelliApi.change_credit_card(
      user.entity_id.to_s,
      user.subscriptions.last.entity_id.to_s,
      card
    )
  end
end
