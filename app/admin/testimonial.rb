# frozen_string_literal: true
ActiveAdmin.register Testimonial do
  menu false

  permit_params :user_id, :message
  before_filter :skip_sidebar!, only: :index

  # filter :author, label: 'Author Name', collection: proc { User.where.not(role: User.roles.values_at(:guest)) }

  index do
    column :id
    column('Author Name') { |t| t.author.name }
    column 'Date Created', sortable: :created_at do |t| t.created_at.strftime(I18n.t('date.formats.default')) end
    column 'Last Updated', sortable: :updated_at do |t| t.updated_at.strftime(I18n.t('date.formats.default')) end
    actions
  end

  form do |f|
    f.inputs do
      # f.input :created_at, label: 'Author Name', as: :autocomplete, url: autocomplete_user_admin_testimonials_path,
      #  input_html: { data: { id_element: '#testimonial_user_id' }, value: f.resource.author.try(:name) }
      # f.input :user_id, as: :hidden
      f.input :user_id, as: :search_select, url: autocomplete_user_admin_testimonials_path, fields: [:first_name]
      f.input :message, label: 'Testimonial', as: :text, input_html: { maxlength: 170 }, hint: 'Max Length 170'
    end
    f.actions
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
