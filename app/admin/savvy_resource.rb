# frozen_string_literal: true
ActiveAdmin.register LearngingLibrary, as: 'SavvyResource' do
  belongs_to :savvy_category
  menu false
  navigation_menu do
    :default
  end

  filter :title_cont, label: 'By Title'

  permit_params :title, :file_type, :file_id, :thumb_id, :status, :featured

  form do |f|
    f.inputs 'Savvy Resource Information' do
      f.input :title
      f.input :file_type, as: :select2, collection:
        LearngingLibrary.file_types.collect { |type|
          [type[0].titleize, type[0]]
        }, include_blank: false, label: 'File Type'
      f.input :file_id, label: 'File Path', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'all'
      }
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
      f.input :featured
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Savvy Resource')
      else
        f.action(:submit, label: 'Update Savvy Resource')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title, sortable: :title
    column :file_type, sortable: :file_type
    actions
  end
end
