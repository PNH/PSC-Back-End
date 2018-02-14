ActiveAdmin.register IssueCategory do
  belongs_to :goal, optional: true
  menu false
  filter :title_cont, label: 'By Issue Category Title'
  navigation_menu do
    :default
  end
  permit_params :title, :status

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',   "/admin"),
     link_to('Goals',             "/admin/goals"),
     link_to('Issue Categories',  "/admin/goals/#{params[:goal_id]}/issue_categories")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:goal_id]
    }
    session[:breadcrumb][:issuecategory] = data
  end

  index do
    column :id
    column :title
    column :status
    column('Issues') do |ic|
      link_to ic.issues.count, admin_issue_category_issues_path(ic)
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Issue Category')
      else
        f.action(:submit, label: 'Update Issue Category')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end
end
