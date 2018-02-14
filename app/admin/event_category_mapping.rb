ActiveAdmin.register EventCategoryMapping do
belongs_to :event
# menu false

scope("Event Categories", default: true) { |scope| scope.where(event_id: params[:event_id]) }

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :event_id, :event_category_id
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
  column('title') do |mapping|
    mapping.event_category.title
  end
  actions
end


end
