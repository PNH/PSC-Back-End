ActiveAdmin.register BlogPostComment do
  belongs_to :blog_post
  actions :all, :except => [:new]
  filter :user
  # menu false
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :user_id, :blog_post_id, :comment, :parent_id
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
  column('User') do |comment|
    if !comment.user.nil?
      link_to "#{comment.user.first_name} #{comment.user.last_name}", url_for([:admin, comment.user])
    else
      "Deleted"
    end
  end
  column :comment
  column :created_at
  actions
end


end
