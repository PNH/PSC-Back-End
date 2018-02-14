ActiveAdmin.register Tag do
	filter :name_cont, label: 'By Name'

  permit_params :name, :slug

  index do
    column :id, sortable: :id
    column :name
    column :slug

    actions
  end

  form do |f|
    inputs 'Tag Information' do
      f.input :name
      f.input :slug
    end
    f.actions
    render 'tag'
  end

end
