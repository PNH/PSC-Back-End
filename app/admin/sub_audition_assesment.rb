ActiveAdmin.register SubAuditionAssesment do
  belongs_to :audition_assesment, optional: true
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
     link_to('Audition Assesments', "/admin/audition_assesments"),
     link_to('Sub Auditions And Self-Assessments', "/admin/audition_assesments/#{params[:audition_assesment_id]}/sub_audition_assesments")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:audition_assesment_id]
    }
    session[:breadcrumb][:auditionassesment] = data
  end

  form do |f|
    f.inputs do
      f.input :kind, as: :hidden, input_html: { value: 'audition' }
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
      link_to topic.audition_resources.count, admin_sub_audition_assesment_audition_resources_path(topic)
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
    lc = SubAuditionAssesment.find(params[:id])
    lc.move_to_top
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    set_item_order
    lc = SubAuditionAssesment.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end

  controller do
    def set_item_order
        ac = AuditionAssesment.find(params[:rid])
        ac.sub_audition_assesments.order(:position).each_with_index do |sac,order|
          sac.position = order+1
          sac.save!
        end
    end
  end

end
