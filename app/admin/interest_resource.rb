ActiveAdmin.register LearngingLibrary, as:  'InterestResource' do
  belongs_to :sub_interest
  menu false
  navigation_menu do
    :default
  end

  filter :title_cont, label: 'By Title'

  permit_params :title, :file_type, :file_id, :thumb_id, :status, :featured

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',         "/admin"),
     link_to('Interests',     "/admin/interests"),
     link_to('Sub Interests', "/admin/interests/#{session[:breadcrumb]['interest']['id']}/sub_interests"),
     link_to('Interest Resources', "/admin/sub_interests/#{params[:sub_interest_id]}/interest_resources")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:sub_interest_id]
    }
    session[:breadcrumb][:subinterest] = data
  end

  form do |f|
    f.inputs 'Interest Resource Information' do
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
        f.action(:submit, label: 'Create Interest Resource')
      else
        f.action(:submit, label: 'Update Interest Resource')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title, sortable: :title
    column :file_type, sortable: :file_type
    actions
  end

  controller do
    def create
      super do |_format|
        unless resource.errors.any?
          flash[:notice] = 'Interest Resource was successfully created.'
        end
      end
    end

    def update
      super do |_format|
        unless resource.errors.any?
          flash[:notice] = 'Interest Resource was successfully updated.'
        end
      end
    end

    def destroy
      super do |_format|
        unless resource.errors.any?
          flash[:notice] = 'Interest Resource was successfully deleted.'
        end
      end
    end
  end
end
