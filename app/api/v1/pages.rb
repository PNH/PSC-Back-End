module V1
  class Pages < Grape::API

    namespace 'pages/meta' do
      get do
        response = { status: 200, message: 'Page types to filter', content: ::Page.display_types }
        return response
      end
    end

    namespace 'pages/:type' do
      params do
        requires :type, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if true
          pages = ::Page.where display_type: params[:type], status: true
          if !pages.empty?
            response = { status: 200, message: "#{pages.count} pages found", content: Entities::Page.represent(pages) }
          else
            response = { status: 200, message: 'No Pages found', content: nil }
          end

        end

        return response
      end
    end

    namespace 'page/:slug' do
      params do
        requires :slug, type: String
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if true
          page = ::Page.find_by slug: params[:slug], status: true
          if !page.nil?
            response = { status: 200, message: "page found", content: Entities::Page::PageDetailed.represent(page) }
          else
            response = { status: 200, message: 'No Pages found', content: nil }
          end

        end

        return response
      end
    end
    #
    # namespace 'pages/:slug/attachments' do
    #
    # end

  end
end
