ActiveAdmin.register Issue do
  belongs_to :goal, optional: true
  belongs_to :issue_category, optional: true

  filter :title_cont, label: 'By Issue'
  permit_params :title, :status, :savvy_id
  menu false
  navigation_menu do
    :default
  end

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',             "/admin"),
     link_to('Goals',             "/admin/goals"),
     link_to('Issue Categories',  "/admin/goals/#{session[:breadcrumb]["issuecategory"]["id"]}/issue_categories"),
     link_to('Issues',            "/admin/issue_categories/#{params[:issue_category_id]}/issues")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:issue_category_id]
    }
    session[:breadcrumb][:issue] = data
  end

  index do
    column :id
    column :title
    actions
  end

  form do |f|
    f.inputs 'Issue Information' do
      f.input :title, label: 'Issue'
      f.input :savvy, as: :select2, collection:
        Savvy.all.collect { |savvy|
          ["#{savvy.level.title} #{savvy.title}", savvy.id]
        }, include_blank: true, label: 'Lesson Type'
    end
    f.actions
  end
end
