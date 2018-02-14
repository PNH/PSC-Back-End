class NetsuiteUpdateEmailJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    Netsuite::ParelliApi.update_email(user.entity_id, user.email)
  end
end
