# frozen_string_literal: true
module V1
  class Savvies < Grape::API
    prefix 'api'

    resource :savvies do
      get do
        savvies = Savvy.all
        {
          status: 200,
          message: '',
          content: Entities::Savvy.represent(savvies, request: request)
        }
      end
    end
  end
end
