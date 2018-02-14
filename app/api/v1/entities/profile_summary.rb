# frozen_string_literal: true
module V1
  module Entities
    class ProfileSummary < Grape::Entity
      expose :id
      expose :birthday do |instance|
        instance.birthday.try { |date| date.strftime(I18n.t('date.formats.default')) }
      end
      expose :first_name
      expose :last_name
      expose :level do |instance|
        instance.level.try(:id)
      end
      expose :relationship do |instance, _options|
        ::User.relationships[instance.relationship]
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
      expose :gender do |instance|
        ::User.genders[instance.gender]
      end
      expose :country do |instance|
        instance.get_country
      end
      expose :profilePic do |instance, _options|
         if instance.profile_picture.nil?
           Rails.application.config.s3_source_path + 'default/UserDefault.png'
         else
           instance.profile_picture.rich_file.url('thumb')
         end
      end
      expose :role do |instance|
        instance.role.to_s
      end
      expose :membership_level do |instance|
        instance.membership_details.last.membership_type.level.to_s if instance.membership_details.present?
      end
      expose :connection_status do |instance, _options|
        _conn_status = instance.connection_status(_options[:current_user].id)
        {
          'id' => _conn_status.empty? ? -1 : _conn_status.first.id,
          'connected' => instance.is_connected(_options[:current_user].id),
          'label' => _conn_status.empty? ? "not connected" : _conn_status.first.connection_status,
          'status' => _conn_status.empty? ? 0 : UserConnection.connection_statuses[_conn_status.first.connection_status]
        }
      end
      expose :wall_posts_count do |instance, _options|
        instance.wall_posts_count
      end
      expose :connections_count do |instance, _options|
        instance.connections_count
      end
    end
  end
end
