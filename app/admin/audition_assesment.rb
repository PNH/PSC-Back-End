ActiveAdmin.register AuditionAssesment do
  menu false

  permit_params :kind, :title, :rich_file_id
  filter :title_cont, label: 'By Title'
  scope :auditions, default: true
  config.sort_order = 'position_asc'

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',             "/admin"),
     link_to('Audition Assesments', "/admin/audition_assesments")
   ]
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
    column('Sub Auditions And Self-Assessments') do |topic|
      link_to topic.children.count, admin_audition_assesment_sub_audition_assesments_path(topic)
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
