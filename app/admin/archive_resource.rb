ActiveAdmin.register LearngingLibrary, as:  'ArchiveResource' do
  belongs_to :sub_archive
  menu false
  navigation_menu do
    :default
  end
  config.sort_order = 'position_asc'
  filter :title_cont, label: 'By Title'
  permit_params :title, :file_type, :file_id, :thumb_id, :status, :featured

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',             "/admin"),
     link_to('Archives', "/admin/archives"),
     link_to('Sub Archives', "/admin/archives/#{session[:breadcrumb]['archives']['id']}/sub_archives"),
     link_to('Archives Resources', "/admin/sub_archives/#{params[:sub_archive_id]}/archive_resources")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:sub_archive_id]
    }
    session[:breadcrumb][:subarchive] = data
  end

  form do |f|
    f.inputs 'Archive Resource Information' do
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
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Archive Resource')
      else
        f.action(:submit, label: 'Update Archive Resource')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title, sortable: :title
    column :file_type, sortable: :file_type
    actions
    handle_column move_to_top_url: lambda { |vr|
      url_for([:move_to_top, :admin, vr])+ "/?rid=#{vr.llcategory_id}"
    }, sort_url: lambda { |vr|
      url_for([:sort, :admin, vr])+ "/?rid=#{vr.llcategory_id}"
    }
  end

  controller do
    def create
      super do |_format|
        unless resource.errors.any?
          flash[:notice] = 'Archive Resource was successfully created.'
        end
      end
    end

    def update
      super do |_format|
        unless resource.errors.any?
          flash[:notice] = 'Archive Resource was successfully updated.'
        end
      end
    end

    def destroy
      super do |_format|
        unless resource.errors.any?
          flash[:notice] = 'Archive Resource was successfully deleted.'
        end
      end
    end

    def set_item_order
        return unless params[:rid].present?
        sa = SubArchive.find(params[:rid])
        sa.archive_resources.order(:position).each_with_index do |ar,order|
          ar.position = order+1
          ar.file_id = 1 if ar.file_id.nil?
          ar.save!
        end
    end
  end

  member_action :move_to_top, method: [:post] do
    set_item_order
    ar = ArchiveResource.find(params[:id])
    ar.move_higher
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    set_item_order
    ar = ArchiveResource.find(params[:id])
    ar.insert_at(params[:position].to_i)
    head :ok
  end

end
