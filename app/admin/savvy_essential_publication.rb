ActiveAdmin.register SavvyEssentialPublication do
  belongs_to :savvy_essential, optional: true
  menu false
  navigation_menu do
    :default
  end

  filter :title_cont, label: 'By Title'

  config.sort_order = 'publication_date_asc'

  permit_params :title, :description, :publication_date, :status, :rich_file_id, :rich_attachment_id, :additional_content

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('ADMIN', "/admin")
   ]
  end

  index do
    column :id, sortable: :id
    column :title do |savvy_essential_publication|
      savvy_essential_publication.publication_date.strftime("%B %Y")
    end
    column :sections do |savvy_essential_publication|
      link_to savvy_essential_publication.savvy_essential_publication_sections.count, admin_savvy_essential_publication_savvy_essential_publication_sections_path(savvy_essential_publication)
    end

    actions
  end

  form do |f|
    inputs 'Savvy Essential Publication' do
      f.input :title
      f.input :description, as: :text
      f.input :publication_date
      f.input :rich_file_id, label: 'Banner (Ideal pixel size - 1200x320)', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }
      f.input :status, as: :select, collection: { 'Active' => true, 'Inactive' => false }, include_blank: false
      f.input :rich_attachment_id, label: 'Printable Action Plan', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'file'
      }
      f.input :additional_content, label: 'Additional Content (URL)'
    end
    f.actions
  end

end
