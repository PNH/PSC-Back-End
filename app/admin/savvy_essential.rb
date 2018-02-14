ActiveAdmin.register SavvyEssential do
  menu false

  filter :title_cont, label: 'By Title'

  permit_params :title, :status

  actions :all, except: [:destroy, :new]

  index do
    column :id, sortable: :id
    column :title
    column :publications do |savvy_essential|
      link_to savvy_essential.savvy_essential_publications.count, admin_savvy_essential_savvy_essential_publications_path(savvy_essential)
    end

    actions
  end

  form do |f|
    inputs 'Savvy Essential Information' do
      f.input :title
      f.input :status, as: :select, collection: { 'Active' => true, 'Inactive' => false }, include_blank: false
    end
    f.actions
  end
end
