# frozen_string_literal: true
ActiveAdmin.register LearngingLibrary do
  menu false

  filter :title_cont, label: 'By Title'
  filter :file_type, label: 'By File Type', as: :select, collection: proc {
    LearngingLibrary.file_types.map do |type|
      [type[0], type[1]]
    end
  }
  filter :featured
  config.sort_order = 'position_asc'
  permit_params :title, :file_type, :file_id, :thumb_id, :status, :featured

  form do |f|
    f.inputs 'Learnging Library Information' do
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
    f.actions
  end

  index do
    column :id
    column :title, sortable: :title
    column 'File Type', sortable: :file_type, &:file_type
    actions
  end

  member_action :move_to_top, method: [:post] do
    ar = LearngingLibrary.find(params[:id])
    ar.move_higher 
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    ar = LearngingLibrary.find(params[:id])
    ar.insert_at(params[:position].to_i)
    head :ok
  end
end
