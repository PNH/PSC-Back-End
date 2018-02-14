# frozen_string_literal: true
ActiveAdmin.register Savvy do
  # menu false
  config.filters = false
  actions :all, except: [ :destroy]
  belongs_to :level, optional: true
  menu false
  navigation_menu do
    :default
  end

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',   "/admin"),
     link_to('Level',   "/admin/levels"),
     link_to('Savvies', "/admin/levels/#{params[:level_id]}/savvies")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:level_id]
    }
    session[:breadcrumb][:savvy] = data
  end

  index do
    column :id
    column :title
    column 'Topics', sortable: :lc_count do |savvy|
      link_to savvy.lesson_categories.count, admin_savvy_lesson_categories_path(savvy)
    end
    actions
  end

  permit_params :title, :rich_file_id

  form do |f|
    f.inputs do
      f.input :title
      f.input :rich_file_id, as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }, label: 'Logo'
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.select('savvies.*,(select count(lc.id) from lesson_categories lc where savvies.id = lc.savvy_id) as  lc_count')
    end
  end
end
