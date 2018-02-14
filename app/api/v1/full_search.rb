# frozen_string_literal: true
module V1
  class FullSearch < Grape::API
    prefix 'api'

    namespace 'fullsearch/filters' do
      get do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?
          _results = ActiveRecord::Base.connection.execute("select distinct(searchable_type) from pg_search_documents")
          types = []
          _results.each do |type|
            types << type["searchable_type"]
          end
          response = { status: 200, message: "#{types.count} types found", content: types }
        end

        return response
      end
    end

    namespace 'fullsearch/find' do
      params do
        requires :query, type: String
        requires :page, type: Integer
        requires :limit, type: Integer
        requires :filters, type: Array[String]
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?
          page = params[:page]
          limit = params[:limit]
          query = params[:query].downcase
          filters = params[:filters]
          # params[:filters].map do |filter|
          #   filters << filter.to_s
          # end
          # byebug()
          # resultsets = PgSearch.multisearch(query).where().not(searchable_type: 'LearngingLibrary').page(page).per(limit)
          resultsets = PgSearch.multisearch(query).where(:searchable_type=> filters).order(id: :desc).page(page).per(limit)

          if !resultsets.empty?
            response = { status: 200, message: "#{resultsets.count} results found", content: Entities::FullSearch.represent(resultsets, current_user: current_user) }
          else
            response = { status: 200, message: 'No Results', content: nil }
          end

        end

        return response
      end
    end

    namespace 'fullsearch/all/:query' do
      params do
        requires :query, type: String
        requires :page, type: Integer
        requires :limit, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?
          page = params[:page]
          limit = params[:limit]
          query = params[:query].downcase

          # resultsets = PgSearch.multisearch(query).where().not(searchable_type: 'LearngingLibrary').page(page).per(limit)
          resultsets = PgSearch.multisearch(query).order(id: :desc).page(page).per(limit)

          if !resultsets.empty?
            response = { status: 200, message: "#{resultsets.count} results found", content: Entities::FullSearch.represent(resultsets, current_user: current_user) }
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
