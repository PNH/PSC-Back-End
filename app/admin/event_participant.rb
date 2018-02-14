ActiveAdmin.register EventParticipant do
belongs_to :event
# menu false

scope("Participants", default: true) { |scope| scope.where(event_id: params[:event_id]) }
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :event_id, :user_id
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  column :id
  column('Participant') do |participant|
    "#{participant.user.first_name} #{participant.user.last_name}"
  end
  column('Email') do |participant|
    participant.user.email
  end
  actions
end

end
