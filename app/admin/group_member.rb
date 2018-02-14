ActiveAdmin.register GroupMember do
  belongs_to :group
# menu false
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
filter :user, label: 'User Name', collection: proc { User.where(role: User.roles[:member]) }

permit_params :group_id, :user_id
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
  column('User') do |member|
    if !member.user.nil?
      link_to "#{member.user.first_name} #{member.user.last_name}", "/admin/users/#{member.user.id}"
    else
      "Deleted User"
    end
  end
  column :created_at
  column :updated_at
  actions
end

form do |f|
  f.inputs do
    f.input :group_id, as: :select,  collection: Group.all.map {|g| [g.title, g.id]}
    f.input :user_id, as: :select,  collection: User.where(role: User.roles[:member]).map {|u| ["#{u.first_name} #{u.last_name}", u.id]}
  end
  f.actions do
    if controller.action_name == 'new'
      f.action(:submit, label: 'Add Member')
    else
      f.action(:submit, label: 'Update Member')
    end
    f.action(:cancel, label: 'Cancel')
  end
end

end
