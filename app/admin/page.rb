# frozen_string_literal: true
ActiveAdmin.register Page do
  menu false
  filter :title_cont, label: 'By Title'
  filter :status, label: 'By Status'
  filter :status, label: 'By Status', as: :select, collection: { "Published" => true, "Unpublished" => false }

  config.sort_order = 'position_asc'

  scope "Menu Items", :menus_only, default: true
  # scope "Promotions", :promotions_only
  scope "Custom Page", :other_only

  permit_params :title, :slug, :content, :created_at, :updated_at, :status, :display_type, :menu_title, :position,
                page_attachments_attributes: [:id, :title, :rich_file_id, :_destroy], tag_ids: []

  index do
    column :id
    column :title, sortable: :title
    column :menu_title, sortable: :menu_title
    column 'Status', sortable: :status do |page|
      page.status ? 'Published' : 'Unpublished'
    end
    column 'Attachments' do |page|
      link_to "#{page.page_attachments.count}", "pages/#{page.id}/page_attachments"
    end

    actions
    handle_column move_to_top_url: lambda { |vr|
      url_for([:move_to_top, :admin, vr])+ "/?rid=#{vr.id}"
    }, sort_url: lambda { |vr|
      url_for([:sort, :admin, vr])+ "/?rid=#{vr.id}"
    }

  end

  form do |f|
    if f.object.new_record?
      f.object.status = true
    end
    render 'page'
    f.inputs 'Page Information' do
      f.input :title
      f.input :slug
      f.input :tags, as: :select2_multiple, multiple: true, collection: Tag.all.collect{ |f| [f.name, f.id] }, include_blank: true
      f.input :content, as: :rich, config: { width: '76%', height: '400px' }
      f.input :display_type
      f.input :menu_title
      f.input :status, as: :select, collection: { "Published" => true, "Unpublished" => false }
    end
    f.inputs do
      f.has_many :page_attachments, heading: 'Attachments', allow_destroy: true, new_record: 'Add' do |pf|
        pf.input :title
        pf.input :rich_file_id, label: 'Documents', as: :rich_picker, config: {
          style: 'width: 400px !important;', type: 'all'
        }
      end
    end
    f.actions
  end

  member_action :move_to_top, method: [:post] do
    # set_item_order
    lc = Page.find(params[:id])
    lc.move_to_top
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    lc = Page.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end

  controller do
    def set_item_order
        # ls = Page.all
        Page.order(:position).each_with_index do |sls,order|
          # byebug
          sls.position = order+1
          sls.save!
        end
    end
  end

end
