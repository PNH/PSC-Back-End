ActiveAdmin.register Group do
  menu false
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  filter :title_cont, label: 'By Title'

  permit_params :description, :status, :privacy_level, :title, :rich_file_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do
    column :id
    column :title
    column :description
    column('Moderators') do |group|
      link_to "#{group.group_moderators.count}", "groups/#{group.id}/group_moderators"
    end
    column('Members') do |group|
      link_to "#{group.group_members.count}", "groups/#{group.id}/group_members"
    end
    column('Posts') do |group|
      link_to "#{group.group_posts.count}", "groups/#{group.id}/group_posts"
    end
    # column :status
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.object.status = true
    f.inputs do
      f.input :title
      f.input :description, as: :rich, config: { width: '76%', height: '400px', 'max-limit' => '100' }
      f.input :rich_file_id, label: 'File Path', as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'all'
      }
      f.input :status
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Group')
      else
        f.action(:submit, label: 'Update Group')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  after_filter :assign_moderator, only: [:create]

  controller do

    def assign_moderator
      _group_id = @group.id
      moderator = GroupModerator.new(
      :group_id => _group_id,
      :user_id => current_admin_user.id
      )
      moderator.save
    end

  end

end
