# frozen_string_literal: true
ActiveAdmin.register Forum do

  menu :label => "Forums"

  permit_params :title, :description, :position, :status, :user_id
  filter :title_cont, label: 'By Title'
  scope :forums, default: true

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',     "/admin"),
     link_to('Forums',    "/admin/forums")
   ]
  end

  form do |f|
    f.inputs do
      f.object.status = true if f.object.status.nil?
      f.object.user = current_admin_user if f.object.user.nil?
      f.input :title
      # f.input :description
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }, :checked => ['Active', true]
      f.input :user_id, as: :hidden
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Forum')
      else
        f.action(:submit, label: 'Update Forum')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title
    column('Sub Forums') do |forum|
      link_to forum.children.count, admin_forum_sub_forums_path(forum)
    end
    column('User') { |t| t.user.nil? ? '' : t.user.name }
    actions
  end

  collection_action :autocomplete_user, method: [:get] do
    term = params[:q]['groupings']['0']['name_contains']
    users = User.member.where('first_name ILIKE ? or last_name ILIKE ?', "%#{term}%", "%#{term}%")
                .order(:first_name).all
    render json: users.map { |user|
                   {
                     id: user.id,
                     name: user.name
                   }
                 }
  end

  controller do
    def destroy
      # super do |_format|
        _forum = Forum.find params[:id]
        if !_forum.sub_forums.empty?
          flash[:error] = 'Delete Sub-Forums before deleting the parent forum.'
          redirect_to admin_forums_path
        else
          super do |_format|
          end
        end
      # end
      # format.html { redirect_to admin_forums_path }
    end
  end
end
