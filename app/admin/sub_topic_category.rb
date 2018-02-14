# frozen_string_literal: true
ActiveAdmin.register SubTopicCategory do
  belongs_to :topic_category
  menu false
  navigation_menu do
    :default
  end

  permit_params :kind, :title, :rich_file_id
  filter :title_cont, label: 'By Title'

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
        f.action(:submit, label: 'Create Sub Topic Category')
      else
        f.action(:submit, label: 'Update Sub Topic Category')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title
    column('Resources') do |topic|
      link_to topic.topic_resources.count, admin_sub_topic_category_topic_resources_path(topic)
    end
    actions
  end
end
