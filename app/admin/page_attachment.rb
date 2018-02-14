ActiveAdmin.register PageAttachment do
  belongs_to :page
  # menu false
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :page, :title, :rich_file_id

filter :title_cont, label: 'By Title'
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
    f.inputs 'Level And Savvy Resource Information' do
      f.input :page
      f.input :title
      f.input :rich_file_id, label: 'File Path', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'all'
      }
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Level And Savvy Resource')
      else
        f.action(:submit, label: 'Update Level And Savvy Resource')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end


end
