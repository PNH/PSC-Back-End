ActiveAdmin.register LevelChecklist do
menu false
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :level_id, :title, :content, :status
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.inputs '' do
    f.input :level, as: :select2
    f.input :title, label: 'Title'
    f.input :content, label: 'Content', as: :rich, config: { width: '76%', height: '400px' }
    f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
  end
  f.actions
end

end
