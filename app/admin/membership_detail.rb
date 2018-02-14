# frozen_string_literal: true
ActiveAdmin.register MembershipDetail do
  menu false
  actions :all, except: [:create, :destroy, :show]

  filter :user, label: 'User Name', collection: proc { User.where.not(role: User.roles.values_at(:guest)) }
  filter :membership_type_level, label: 'Membership Level', as: :select, collection: proc {
    MembershipType.levels.map do |type|
      [type[0].titleize, type[1]]
    end
  }
  filter :membership_type_billing_frequency, label: 'Membership Type', as: :select, collection: proc {
    MembershipType.billing_frequencies.map do |type|
      [type[0].titleize, type[1]]
    end
  }

  index do
    column :id
    column('User Name') { |md| md.user.name }
    column('Membership Level') { |md| md.membership_type.level }
    column('Membership Type') { |md| md.membership_type.billing_frequency }
    column('User Email') { |md| md.user.email }
    column('Purchase Date') { |md| md.created_at.strftime(I18n.t('date.formats.default')) }
    column('Total', &:total)
    actions
  end

  form do |f|
    f.inputs 'Order Details' do
      f.input :created_at, as: :string, label: 'Order Date', input_html: {
        value: f.resource.created_at.strftime(I18n.t('date.formats.default')),
        readonly: true
      }
      f.input :created_at, as: :string, label: 'Order Time', input_html: {
        value: f.resource.created_at.strftime(I18n.t('time.formats.default')),
        readonly: true
      }
      f.input :created_at, as: :select2, collection:
        ['Pending Payment', 'Complete'], label: 'Order Status'
    end
    f.inputs 'Billing Details' do
      li class: 'text input required' do
        label 'First Name'
        div f.resource.user.first_name
      end
      li class: 'text input required' do
        label 'Last Name'
        div f.resource.user.last_name
      end
      li class: 'text input required' do
        label 'Street Address'
        div f.resource.billing_address.street
      end
      li class: 'text input required' do
        label 'Billing Address 2'
        div f.resource.billing_address.street2
      end
      li class: 'text input required' do
        label 'City'
        div f.resource.billing_address.city
      end
      li class: 'text input required' do
        label 'State'
        div f.resource.billing_address.state
      end
      li class: 'text input required' do
        label 'Zip/Post Code'
        div f.resource.billing_address.zipcode
      end
      li class: 'text input required' do
        label 'Country'
        div f.resource.billing_address.country
      end
      li class: 'text input required' do
        label 'Referral Code'
        div '-'
      end
      li class: 'text input required' do
        label 'Payment Method'
        div '-'
      end
      li class: 'text input required' do
        label 'Transaction ID'
        div '-'
      end
    end
    f.inputs 'Order Items' do
      render 'order_item'
    end
    actions
  end
end
