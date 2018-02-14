ActiveAdmin.register PublicationSection do
  menu false

  filter :title_cont, label: 'By Title'

  permit_params :title, :description, :status

  index do
    column :id, sortable: :id
    column :title
    column :status

    actions
  end

  form do |f|
    inputs 'Section Information' do
      f.input :title
      f.input :description, as: :rich, config: {
        'max-limit' => '100'
      }
      f.input :status, as: :select, collection: { 'Active' => true, 'Inactive' => false }, include_blank: false
    end
    f.actions
  end
end
