# frozen_string_literal: true
ActiveAdmin.register User do
  menu false
  scope 'Members', default: true do |scope|
    scope.where(role: 3).where.not(entity_id: -1) # set -1 for temporally members
  end
  scope :guest
  scope 'Admins', default: true do |scope|
    scope.where('role = 0 OR role = 1')
  end

  filter :first_name_or_last_name_cont, as: :string, label: 'By Name'
  filter :email_cont, label: 'By Email'
  filter :role, label: 'By Role', as: :select, collection: proc {
    User.roles.map do |type|
      next if type[0].eql?('guest')
      [type[0].titleize, type[1]]
    end.select(&:presence)
  }

  index do
    column :id
    column :name
    column :email
    column('Role') do |user|
      user.role.titleize
    end
    column('Membership Level') do |user|
      md = user.membership_details.last
      if md.nil?
        '-'
      else
        md.membership_type.level
      end
    end
    actions
  end

  permit_params :first_name, :last_name, :email, :telephone, :birthday, :gender,
                :relationship, :equestrain_style, :equestrain_interest, :music,
                :books, :profile_picture_id,
                :website, :bio, :role, :password, :password_confirmation,
                home_address_attributes: [:street, :latitude, :longitude,
                                          :id, :country, :state, :city, :zipcode],
                billing_address_attributes: [:street, :zipcode, :latitude,
                                             :longitude, :id, :country, :state, :city]

  form do |f|
    inputs 'Profile Information' do
      f.input :first_name, label: 'First Name'
      f.input :last_name, label: 'Last Name'
      f.input :email
      f.input :telephone
      f.input :birthday, as: :string, label: 'Date of Birth',
                         input_html: { class: 'hasDatetimePicker', value: f.resource.birthday.try { |date| date.strftime(I18n.t('date.formats.default')) } }
      f.input :birthday, as: :hidden, value: f.resource.birthday
      f.input :gender, as: :radio, collection:
        User.genders.collect { |type|
          [type[0].titleize, type[0]]
        }
      f.input :relationship, as: :select2, collection:
        User.relationships.collect { |type|
          [type[0].titleize, type[0]]
        }
      f.input :equestrain_style, as: :select2, collection:
        User.equestrain_styles.collect { |type|
          [type[0].titleize, type[0]]
        }, label: 'Equestrian Style'
      # f.input :equestrain_interest, as: :select2, collection:
      #   User.equestrain_interests.collect { |type|
      #     [type[0].titleize, type[0]]
      #   }, label: 'Equestrian Interest'
      f.input :music
      f.input :books
      f.input :website
      f.input :bio
      f.input :role, as: :select2, collection:
        User.roles.collect { |type|
          [type[0].titleize, type[0]]
        }
      f.input :profile_picture_id, as: :rich_picker, config: {
        style: 'width: 400px !important;', type: 'image'
      }
      f.input :password
      f.input :password_confirmation, label: 'Password Confirmation'
    end
    inputs 'Home Address', for: [:home_address, f.object.home_address || Address.new] do |af|
      af.input :country, include_blank: true, as: :select2, collection: ISO3166::Country.translations.collect{ |cnt|
        [cnt[1], cnt[0]]
      }
      af.input :state, as: :autocomplete, url: autocomplete_state_admin_users_path
      af.input :city, as: :autocomplete, url: autocomplete_city_admin_users_path
      af.input :street
      af.input :zipcode
      af.input :latitude, label: 'Latitude'
      af.input :longitude, label: 'Longitude'
      render 'map'
    end

    unless f.object.new_record?
      inputs 'Billing Address', for: [:billing_address, f.object.billing_address || Address.new] do |af|
        af.input :country, include_blank: true, as: :select2, collection: ISO3166::Country.translations.collect{ |cnt|
          [cnt[1], cnt[0]]
        }
        af.input :state, as: :autocomplete, url: autocomplete_state_admin_users_path
        af.input :city, as: :autocomplete, url: autocomplete_city_admin_users_path
        af.input :street
        af.input :zipcode
        af.input :latitude, label: 'Latitude'
        af.input :longitude, label: 'Longitude'
      end
      # inputs 'Membership Information' do
      # end
    end
    f.actions
  end

  collection_action :autocomplete_state, method: [:get] do
    render json: CS.states(params[:country])
  end

  collection_action :autocomplete_city, method: [:get] do
    render json: CS.cities(CS.states('US').key(params[:state]), params[:country])
  end
end
