ActiveAdmin.register GroupPost do
  belongs_to :group
# menu false
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
filter :user, label: 'User Name', collection: proc { User.where.not(role: User.roles[:guest]) }
permit_params :user_id, :content, :status, :group_id
actions :all, except: [:new]
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
  column('Owner') do |post|
    if !post.user.nil?
      link_to "#{post.user.first_name} #{post.user.last_name}", "/admin/users/#{post.user.id}"
    else
      "Deleted User"
    end
  end
  column :content
  column('Likes') do |post|
    "#{post.group_post_like.count}"
  end
  column :status
  column :created_at
  column :updated_at
  actions
end

end
