# frozen_string_literal: true
ActiveAdmin.register MemberMinuteSection do
  menu false

  filter :title_cont, label: 'By Title'
  permit_params :title, :description, :status, :kind, :file_type, :rich_file_id
  belongs_to :member_minute, optional: true

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',                   "/admin"),
     link_to('Member Minutes',          "/admin/member_minutes"),
     link_to('Member Minute Sections',  "/admin/member_minutes/#{params[:member_minute_id]}/member_minute_sections")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:member_minute_id]
    }
    session[:breadcrumb][:memberminute] = data
  end

  form do |f|
    f.inputs 'Member Minute Section Information' do
      f.object.status = true if f.object.status.nil?
      f.input :title   
      f.input :description, as: :rich, config: { width: '76%', height: '400px' }    
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
      f.input :kind, as: :select, collection:
       MemberMinuteSection.categoryselects.collect { |type|
        # unless f.object.memberminute.memberminute_sections.where('kind = 1').count > 0 && type[1] ==1
         [type[0].titleize, type[1]]
        # end
       }, include_blank: false, label: 'Category'
       f.input :file_type, as: :select2, collection:
       MemberMinuteSection.file_types.collect { |type|
         [type[0].titleize, type[0]]
       }, include_blank: false, label: 'File Type'
       f.input :rich_file_id, label: 'File Path', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'all'
      }
    end
    f.actions
  end

  index do
    column :id
    column :title, sortable: :title    
    actions
  end
end
