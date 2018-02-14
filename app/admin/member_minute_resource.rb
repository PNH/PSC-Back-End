# frozen_string_literal: true
ActiveAdmin.register MemberMinuteResource do
  menu false

  filter :title_cont, label: 'By Title'
  filter :kind, label: 'By Kind', as: :select, collection: proc {
    MemberMinuteResource.kinds.map do |type|
      [type[0], type[1]]
    end
  }
  belongs_to :member_minute_section, optional: true
  permit_params :title, :kind, :rich_file_id, :external_url, :description

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',                   "/admin"),
     link_to('Member Minutes',          "/admin/member_minutes"),
     link_to('Member Minute Sections',  "/admin/member_minutes/#{session[:breadcrumb]['memberminute']['id']}/member_minute_sections"),
     link_to('Audition Resources',      "/admin/member_minute_sections/#{params[:member_minute_section_id]}/member_minute_resources")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:member_minute_section_id]
    }
    session[:breadcrumb][:memberminutesection] = data
  end

  form do |f|
    f.inputs 'Member Minute Resource Information' do
      # f.input :title
      # f.input :description
      # f.input :external_url
      f.input :kind, as: :select2, collection:
       MemberMinuteResource.kinds.collect { |type|
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
    column 'Kind', sortable: :kind, &:kind
    actions
  end

end
