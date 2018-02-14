ActiveAdmin.register LevelAndSavvy do
  menu false

  permit_params :kind, :title, :rich_file_id
  filter :title_cont, label: 'By Title'
  scope :level_savvies, default: true
  config.sort_order = 'position_asc'

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',             "/admin"),
     link_to('Level And Savvies', "/admin/level_and_savvies")
   ]
  end

  form do |f|
    f.inputs do
      f.input :kind, as: :hidden, input_html: { value: 'level_savvy' }
      f.input :title
      f.input :rich_file_id, label: 'Thumbnail', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }
    end
    f.actions
  end

  index do
    column :id
    column :title
    column('Sub Level & Savvy') do |topic|
      link_to topic.children.count, admin_level_and_savvy_sub_level_and_savvies_path(topic)
    end
    actions
    handle_column move_to_top_url: lambda { |vr|
      url_for([:move_to_top, :admin, vr])+ "/?rid=#{vr.parent_id}"
    }, sort_url: lambda { |vr|
      url_for([:sort, :admin, vr])+ "/?rid=#{vr.parent_id}"
    }
  end

  member_action :move_to_top, method: [:post] do
    set_item_order
    lc = Archive.find(params[:id])
    lc.move_to_top
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    set_item_order
    lc = Archive.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end

  controller do
    def set_item_order
        return unless params[:rid].present?
        ar = Archive.where parent_id: nil
        ar.order(:position).each_with_index do |sa,order|
          sa.position = order+1
          sa.save!
        end
    end
  end
end
