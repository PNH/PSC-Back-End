class NetsuiteUpdatePasswordJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, password)
    user = User.find(user_id)
    Netsuite::ParelliApi.update_password(user.entity_id.to_s, password)
  end
end
