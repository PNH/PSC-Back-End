ActiveAdmin.register SubLevelAndSavvy do
  belongs_to :level_and_savvy, optional: true
  menu false
  navigation_menu do
    :default
  end
  config.sort_order = 'position_asc'

  permit_params :kind, :title, :rich_file_id
  filter :title_cont, label: 'By Title'

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',             "/admin"),
     link_to('Level And Savvies', "/admin/level_and_savvies"),
     link_to('Sub Level And Savvies', "/admin/level_and_savvies/#{params[:level_and_savvy_id]}/sub_level_and_savvies")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:level_and_savvy_id]
    }
    # byebug
    session[:breadcrumb][:levelnsavvy] = data
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
    column('Resources') do |topic|
      link_to topic.level_and_savvy_resources.count, admin_sub_level_and_savvy_level_and_savvy_resources_path(topic)
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
    lc = SubLevelAndSavvy.find(params[:id])
    lc.move_to_top
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    set_item_order
    lc = SubLevelAndSavvy.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end

  controller do
    def set_item_order
        ls = LevelAndSavvy.find(params[:rid])
        ls.sub_level_and_savvies.order(:position).each_with_index do |sls,order|
          sls.position = order+1
          sls.save!
        end
    end
  end

end
