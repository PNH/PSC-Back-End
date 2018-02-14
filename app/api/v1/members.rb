# frozen_string_literal: true
module V1
  class Members < Grape::API
    prefix 'api'

    namespace 'members/instructors/search/:query' do
      params do
        requires :query, type: String
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?
          query = params[:query].downcase
          instructors = User.where("lower(first_name || ' ' || last_name) LIKE ? AND is_instructor = true", "%#{query}%").limit(25)
          # instructors = []
          # tmpusers.each do |user|
          #   if user.is_instructor === true
          #     instructors.push(user)
          #   end
          # end

          if !instructors.empty?
            response = { status: 200, message: 'Found', content: Entities::Members.represent(instructors) }
          else
            response = { status: 200, message: 'No Results', content: nil }
          end

        end

        return response
      end
    end

    helpers do
    end

  end
end
