ActiveAdmin.register EventInstructor do
belongs_to :event
# menu false

scope("Instructors", default: true) { |scope| scope.where(event_id: params[:event_id]) }

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :event_id, :user_id, :join_type
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.inputs do
    f.input :event_id, as: :select,  collection: Event.where(status: Event.statuses[:open]).map {|e| [e.title, e.id]}
    f.input :user_id, as: :select,  collection: User.where(is_instructor: true).map {|u| [u.first_name, u.id]}
  end
  f.actions do
    if controller.action_name == 'new'
      f.action(:submit, label: 'Add Instructor')
    else
      f.action(:submit, label: 'Update Instructor')
    end
    f.action(:cancel, label: 'Cancel')
  end
end

index do
  column :id
  column('Instructor') do |instructor|
    "#{instructor.user.first_name} #{instructor.user.last_name}"
  end
  column('Email') do |instructor|
    instructor.user.email
  end
  actions
end


end
