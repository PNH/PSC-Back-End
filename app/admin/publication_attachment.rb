ActiveAdmin.register PublicationAttachment do
  belongs_to :savvy_essential_publication_section, optional: true
  menu false
  navigation_menu do
    :default
  end

  filter :name_cont, label: 'By Name'

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('ADMIN',   "/admin"),
     link_to('SAVVY ESSENTIAL PUBLICATION SECTIONS ',   "/admin/savvy_essential_publications/#{session[:breadcrumb]['savvy_essential_publication_section']['id']}/savvy_essential_publication_sections")
   ]
  end

  permit_params :name, :rich_file_id

  index do
    column :id, sortable: :id
    column :name

    actions
  end

  form do |f|
    inputs 'Publication Attachments' do
      f.input :name
      f.input :rich_file_id, label: 'File Path', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'all'
      }
    end
    f.actions
  end

end
