# frozen_string_literal: true
module V1
  module Entities
    class Profile < Grape::Entity
      expose :id, :email, :music, :books, :website, :bio, :humanity
      expose :birthday do |instance|
        instance.birthday.try { |date| date.strftime(I18n.t('date.formats.default')) }
      end
      expose :first_name, as: :firstName
      expose :last_name, as: :lastName
      expose :level do |instance|
        instance.level.try(:id)
      end
      expose :relationship do |instance, _options|
        ::User.relationships[instance.relationship]
      end
      expose :equestrainStyle do |instance, _options|
        ::User.equestrain_styles[instance.equestrain_style]
      end
      expose :equestrainInterest do |instance, _options|
        # ::UserEquestrainInterest.equestrain_interests[instance.equestrain_interest]
        interests = []
        instance.user_equestrain_interests.each do |equestrain_interest|
          # interest = {
          #   "id": equestrain_interest.equestrain_interest_id,
          #   "name": UserEquestrainInterest.equestrain_interests[equestrain_interest.equestrain_interest_id]
          # }
          interests << equestrain_interest.equestrain_interest_id
        end
        interests
      end
      expose :humanity do |instance|
        ::User.humanities[instance.humanity]
      end
      expose :gender do |instance|
        ::User.genders[instance.gender]
      end
      expose :home_address, using: V1::Entities::Address, as: :homeAddress
      expose :billing_address, using: V1::Entities::Address, as: :billingAddress
      expose :profilePic do |instance, _options|
         if instance.profile_picture.nil?
           Rails.application.config.s3_source_path + 'default/UserDefault.png'
         else
           instance.profile_picture.rich_file.url('thumb')
         end
      end
      expose :currency_id, as: :currencyId
      expose :role do |instance|
        instance.role.to_s
      end
      expose :membership_level do |instance|
        instance.membership_details.last.membership_type.level.to_s  if instance.membership_details.present?
      end
      expose :unread_messages_count do |instance, _options|
        instance.unread_messages_count
      end
      expose :wall_posts_count  do |instance, _options|
        instance.wall_posts_count
      end
      expose :connections_count  do |instance, _options|
        instance.connections_count
      end
      expose :instructors do |instance, _options|
        instructors = []
        current_user = _options[:current_user]
        instance.instructors.each do |instructor|
          user = ::User.find_by id: instructor.instructor_id
          if !user.nil?
            instructors << V1::Entities::User.userPublicMiniTemplate(user, instance)
          end
        end
        instructors
      end
    end
  end
end
