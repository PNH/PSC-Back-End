# frozen_string_literal: true
module V1
  module Entities
    class Notification < Grape::Entity
      expose :id, :status, :created_at, :message
      # rails truncate made some issues, if any update
      expose :wall_message do |instance|
        instance.message.nil? ? nil : (instance.message.length > 48) ? instance.message[0..48].strip + "..." : instance.message
      end
      expose :notification_type do |instance, _options|
        instance.notification_type.nil? ? "system" : instance.notification_type
      end
      expose :sender do |instance, _options|
        unless instance.user.nil?
        owner = {
          'id' => instance.user.id,
          'firstName' => instance.user.first_name,
          'lastName' => instance.user.last_name,
          'profileImage' => instance.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.user.profile_picture.rich_file.url('thumb')
        }
        end
        owner
      end

      expose :notifiable do |instance|
        case instance.notifiable_type
        when "BlogPost"
          ::BlogPost.where(id: instance.notifiable_id).select(:id, :slug)[0]
        else
          nil
        end
      end
    end
  end
end
