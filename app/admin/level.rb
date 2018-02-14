ActiveAdmin.register Level do
  menu false
  config.filters = false
  config.sort_order = 'id_asc'
  actions :all, except: [:new, :destroy]

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',   "/admin"),
     link_to('Level',   "/admin/levels")
   ]
  end

  index do
    column :id
    column :title
    column :color
    column('Savvy') do |level|
      link_to level.savvies.count, admin_level_savvies_path(level)
    end
    actions
  end

  permit_params :title, :color

  form do |f|
    f.inputs do
      f.input :title
      f.input :color
    end
    f.actions
  end
end
