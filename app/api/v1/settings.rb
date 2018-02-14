# frozen_string_literal: true
module V1
  class Settings < Grape::API
    prefix 'api'
    resource :settings do
      params do
        requires :slug, type: String
      end
      route_param :slug do
        get do
          setting = ::Settings::Setting.find_by(slug: params[:slug])
          {
            status: 200,
            message: '',
            content: {
              'slug' => params[:slug],
              'value' => setting.try(:value) || ''
            }
          }
        end
      end
    end

    resource :currencies do
      get do
        currencies = Currency.all
        {
          status: 200,
          message: '',
          content: Entities::Currency.represent(currencies)
        }
      end
    end
  end
end
