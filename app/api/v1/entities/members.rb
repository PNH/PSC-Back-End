# frozen_string_literal: true
module V1
  module Entities
    class Members < Grape::Entity
      expose :id
      expose :first_name, as: :firstName
      expose :last_name,  as: :lastName
      expose :profileImage do |instance, options|
        instance.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.profile_picture.url('thumb')
      end
    end
  end
end
