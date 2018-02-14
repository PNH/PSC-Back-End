# frozen_string_literal: true
ActiveAdmin.register MemberMinute do

  menu :label => "Member Minutes"

  filter :title_cont, label: 'By Title'
  permit_params  :title, :description, :status, :publish_date, :pdf_id, :pdf_remote_url , :featured, :short_description, :rich_file_id, :memberminute_section, :savvytime_section

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',             "/admin"),
     link_to('Member Minutes',    "/admin/member_minutes")
   ]
  end

  form do |f|
    f.inputs 'Member Minute Information' do
      f.object.status = true if f.object.status.nil?

      f.input :title
      # f.input :description
      # f.input :short_description
      f.input :savvytime_section, label: 'Savvy Time Title'
      f.input :memberminute_section, label: 'Member Minute Title'      
      f.input :rich_file_id, as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }, label: 'Background Image'
      f.input :pdf_id, as: :rich_picker, config: {
        type: 'file', style: 'width: 400px !important;'
      }, label: 'PDF File'
      f.input :pdf_remote_url, label: 'Digital Url'
      f.input :publish_date, label: 'Publish Date', as: :string,
                           input_html: { class: 'hasDatetimePicker', value: f.resource.publish_date.try { |date| date.strftime('%m/%d/%Y') } }

      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
      f.input :featured
    end
    f.actions
  end

  index do
    column :id
    column :title, sortable: :title
    column :memberminute_sections do |ms|
      link_to ms.member_minute_sections.count, admin_member_minute_member_minute_sections_path(ms)
    end
    column :featured
    column :publish_date, sortable: :publish_date do |ms|
      ms.publish_date.strftime('%m/%d/%Y')
    end
    actions
  end

  controller do
    after_save do |id = self.id|
      id = params[:id].nil? ? id : params[:id]
      if MemberMinute.where("featured=true").count > 1
         MemberMinute.where("featured=true AND id<>?", id).update_all :featured => false
      end
      true
    end
  end




end
