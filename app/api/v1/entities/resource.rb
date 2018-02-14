# frozen_string_literal: true
module V1
  module Entities
    class Resource < Grape::Entity
      expose :id, :user_id, :kind, :status, :created_at
      expose 'file' do |instance|
        instance.file.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.file.url('original')
      end
    end
  end
end
