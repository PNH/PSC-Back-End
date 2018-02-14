ActiveAdmin.register SavvyEssentialPublicationSection do
	belongs_to :savvy_essential_publication, optional: true
  menu false
  navigation_menu do
    :default
  end

  config.sort_order = 'position_asc'

  filter :description_cont, label: 'By Description'

  permit_params :description, :status, :publication_section_id
  # title removed
  # :title

  before_filter only: :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      controller: params[:controller],
      id: params[:savvy_essential_publication_id]
    }
    session[:breadcrumb][:savvy_essential_publication_section] = data
  end

  index do
    column :id, sortable: :id
    column('Title') do |savvy_essential_publication_section|
      savvy_essential_publication_section.publication_section.title
    end
    column('Resources') do |savvy_essential_publication_section|
      link_to savvy_essential_publication_section.publication_attachments.count, admin_savvy_essential_publication_section_publication_attachments_path(savvy_essential_publication_section)
    end
    actions

    handle_column move_to_top_url: lambda { |vr|
      url_for([:move_to_top, :admin, vr.savvy_essential_publication, vr]) + "/?rid=#{vr.id}"
    }, sort_url: lambda { |vr|
      url_for([:sort, :admin, vr.savvy_essential_publication, vr])+ "/?rid=#{vr.id}"
    }
  end

  form do |f|
    inputs 'Savvy Essential Publication Information' do
      # f.input :title
      f.input :publication_section_id, label: 'Publication Section', as: :select,  collection: PublicationSection.where(status: true).map { |t| [t.title.to_s, t.id] }
      f.input :description, as: :rich, config: {
        'max-limit' => '100'
      }
      f.input :status, as: :select, collection: { 'Active' => true, 'Inactive' => false }, include_blank: false
    end
    f.actions
  end

  member_action :move_to_top, method: [:post] do
    lc = SavvyEssentialPublicationSection.find(params[:id])
    lc.move_to_top
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    lc = SavvyEssentialPublicationSection.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end
end
