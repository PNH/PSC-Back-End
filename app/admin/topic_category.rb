# frozen_string_literal: true
ActiveAdmin.register TopicCategory do
  menu false

  permit_params :kind, :title, :rich_file_id
  filter :title_cont, label: 'By Title'
  scope :topics, default: true

  form do |f|
    f.inputs do
      f.input :kind, as: :hidden, input_html: { value: 'topic' }
      f.input :title
      f.input :rich_file_id, label: 'Thumbnail', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Topic Category')
      else
        f.action(:submit, label: 'Update Topic Category')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title
    column('Sub Topics') do |topic|
      link_to topic.children.count, admin_topic_category_sub_topic_categories_path(topic)
    end
    actions
  end
end
