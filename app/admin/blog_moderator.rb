ActiveAdmin.register BlogModerator do
menu false
# filter :user, label: 'Moderator', collection: proc { User.where.not(role: User.roles[:guest]) }
permit_params :blog_id, :user_id, :moderator_type
before_filter :skip_sidebar!, only: :index
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
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
  column('User') do |moderator|
    "#{moderator.user.first_name} #{moderator.user.last_name}"
  end
  column :moderator_type
  column :created_at
  actions
end

form do |f|
  f.inputs do
    f.input :blog_id, as: :select,  collection: Blog.all.map {|g| [g.name, g.id]}
    f.input :user_id, as: :select,  collection: User.where.not(role: User.roles[:guest]).map {|u| ["#{u.first_name} #{u.last_name}", u.id]}
    f.input :moderator_type, as: :select2, collection:
      BlogModerator.moderator_types.collect { |type|
        [type[0].titleize, type[0]]
      }, include_blank: false, label: 'Type'
  end
  f.actions do
    if controller.action_name == 'new'
      f.action(:submit, label: 'Add Moderator')
    else
      f.action(:submit, label: 'Update Moderator')
    end
    f.action(:cancel, label: 'Cancel')
  end
end


end
