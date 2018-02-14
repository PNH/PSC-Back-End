ActiveAdmin.register Post do
  menu false
  belongs_to :forum
  navigation_menu do
    :default
  end

  permit_params :message, :content, :position, :status, :user_id 
  filter :user, label: 'Author Name', collection: proc { User.where.not(role: User.roles.values_at(:guest)) }

  form do |f|
    f.inputs do
      f.input :message
      f.input :content
      f.input :user_id, as: :search_select, url: autocomplete_user_admin_forum_post_path, fields: [:first_name]
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Post')
      else
        f.action(:submit, label: 'Update Post')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :message
    column('Author Name') { |t| t.user.name }
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

end
