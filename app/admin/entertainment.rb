# frozen_string_literal: true
ActiveAdmin.register TopicCategory, as: 'Entertainment' do
  menu false

  permit_params :kind, :title, :rich_file_id
  filter :title_cont, label: 'By Title'
  scope :entertainments, default: true

  form do |f|
    f.inputs do
      f.input :kind, as: :hidden, input_html: { value: 'entertainment' }
      f.input :title
      f.input :rich_file_id, label: 'Thumbnail', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Entertainment')
      else
        f.action(:submit, label: 'Update Entertainment')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title
    column('Resources') do |topic|
      link_to topic.children.count, admin_entertainment_entertainment_resources_path(topic)
    end
    actions
  end
end
