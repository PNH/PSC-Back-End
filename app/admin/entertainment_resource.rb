# frozen_string_literal: true
ActiveAdmin.register LearngingLibrary, as: 'EntertainmentResource' do
  belongs_to :entertainment
  menu false
  navigation_menu do
    :default
  end

  filter :title_cont, label: 'By Title'

  permit_params :title, :file_type, :file_id, :thumb_id, :status, :featured

  form do |f|
    f.inputs 'Entertainment Resource Information' do
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
        f.action(:submit, label: 'Create Entertainment Resource')
      else
        f.action(:submit, label: 'Update Entertainment Resource')
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
