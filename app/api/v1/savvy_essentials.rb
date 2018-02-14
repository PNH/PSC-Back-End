# frozen_string_literal: true
module V1
  class SavvyEssentials < Grape::API
    prefix 'api'

    # SavvyEssentials
    namespace 'savvy-essentials' do
      params do
        requires :currentDate, type: DateTime
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

        publication = SavvyEssentialPublication.latest_issue_savvy(params[:currentDate])

        return {
          status: 200,
          message: 'latest savvy essentials',
          content: Entities::SavvyEssential.represent(publication)
        }
      end
    end
  end
end
