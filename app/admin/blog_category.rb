ActiveAdmin.register BlogCategory do
	menu false

  filter :name_cont, label: 'By Name'

  permit_params :name

  index do
    column :id, sortable: :id
    column :name

    actions
  end

  form do |f|
    inputs 'Blog Category' do
      f.input :name, label: 'Category Name'
    end
    f.actions
  end
end
