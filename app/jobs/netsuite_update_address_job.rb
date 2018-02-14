class NetsuiteUpdateAddressJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    user = User.find(id)
    Netsuite::ParelliApi.update_address(
      user.entity_id.to_s,
      user.billing_address
    )
  end
end
