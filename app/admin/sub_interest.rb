ActiveAdmin.register SubInterest do
  menu false
  belongs_to :interest, optional: true
  navigation_menu do
    :default
  end
  config.sort_order = 'position_asc'

  permit_params :kind, :title, :rich_file_id
  filter :title_cont, label: 'By Title'

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',         "/admin"),
     link_to('Interests',     "/admin/interests"),
     link_to('Sub Interests', "/admin/interests/#{params[:interest_id]}/sub_interests")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:interest_id]
    }
    session[:breadcrumb][:interest] = data
  end

  form do |f|
    f.inputs do
      f.input :kind, as: :hidden, input_html: { value: 'interest' }
      f.input :title
      f.input :rich_file_id, label: 'Thumbnail', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Sub-Interest')
      else
        f.action(:submit, label: 'Update Sub-Interest')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title
    column('Resources') do |topic|
      link_to topic.interest_resources.count, admin_sub_interest_interest_resources_path(topic)
    end
    actions
    handle_column
  end

  member_action :move_to_top, method: [:post] do
    set_item_order
    lc = SubInterest.find(params[:id])
    lc.move_to_top
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    set_item_order
    lc = SubInterest.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end

  controller do
    def set_item_order
        it = Interest.find(params[:id])
        it.sub_interests.order(:position).each_with_index do |sit,order|
          sit.position = order+1
          sit.save!
        end
    end
  end

end
