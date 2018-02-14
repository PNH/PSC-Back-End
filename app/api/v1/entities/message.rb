# frozen_string_literal: true
module V1
  module Entities
    class Message < Grape::Entity
      expose :id, :content, :created_at
      expose :status do |instance, _options|
        current_user = _options[:current_user]
        mrs = instance.message_recipient.where(user_id: current_user.id)
        status = false
        unless mrs.empty?
          status = mrs.first.status
        end
        status
      end
      expose :sender do |instance, _options|
        # instance.user.id unless instance.user.nil?
        unless instance.user.nil?
              owner = {
                'id' => instance.user.id,
                'firstName' => instance.user.first_name,
                'lastName' => instance.user.last_name,
                'profileImage' => instance.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.user.profile_picture.rich_file.url('thumb')
              }
              else
              owner = {
                'id' => 0,
                'firstName' => 'Deleted',
                'lastName' => 'User',
                'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
              }
            end
      end
      expose :recipients do |instance, _options|
        recipients_list = []
        unless instance.recipients.empty?
            instance.recipients.each do |recipient|
              # recipients_list << recipient.id
              unless recipient.nil?
              reci = {
                'id' => recipient.id,
                'firstName' => recipient.first_name,
                'lastName' => recipient.last_name,
                'profileImage' => recipient.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : recipient.profile_picture.rich_file.url('thumb')
              }
              else
              reci = {
                'id' => 0,
                'firstName' => 'Deleted',
                'lastName' => 'User',
                'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
              }              
            end
            recipients_list << reci
            end
        end
        recipients_list
      end
    end
  end
end
