# frozen_string_literal: true
module V1
  class Tags < Grape::API
    prefix 'api'

    namespace 'tags' do
      params do
        requires :name, type: String
      end
      post do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: nil
          }
        end

        publication = Tag.new(name: params[:name])
        if publication.save!
          return {
            status: 200,
            message: 'latest savvy essentials',
            content: publication
          }
        else
          return {
            status: 500,
            message: 'Failed to add tag',
            content: nil
          }
        end
      end
    end
  end
end
