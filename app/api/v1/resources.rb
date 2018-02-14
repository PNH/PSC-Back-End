
module V1
  class Resources < Grape::API
    prefix 'api'

    namespace 'resources/kinds' do
      get do
        response = { status: 200, message: 'Resource types', content: ::Resource.kinds }
      end
    end

    namespace 'resources/:id' do
      params do
        requires :id, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          resource = ::Resource.find_by id: params[:id]
          if !resource.nil?
            response = { status: 200, message: 'Resource found', content: Entities::Resource.represent(resource) }
          else
            response = { status: 404, message: 'Resource not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :kind, type: Integer
        requires :file, :type => Rack::Multipart::UploadedFile, :desc => "Resource file."
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          _resource = Rich::RichFile.new
          _file_attrs = params[:file]
          _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
          _resource.rich_file = _file_params
          _resource.rich_file_file_name = _file_attrs[:filename]

          resource = ::Resource.new(file: _resource, status: ::Resource.status[:enabled], kind: params[:kind], user_id: current_user.id)
          if resource.save
            response = { status: 201, message: 'Filed uploaded', content: Entities::Resource.represent(resource) }
          else
            response = { status: 500, message: 'Failed to save file', content: nil }
          end
        end

        return response
      end

      params do 
        requires :id, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          resource = ::Resource.find_by id: params[:id]
          if !resource.nil?
            if resource.destroy
              response = { status: 200, message: 'Resource removed', content: nil }
            else
              response = { status: 500, message: 'Failed to removed', content: Entities::Resource.represent(resource) }
            end
          else
            response = { status: 404, message: 'Resource not found', content: nil }
          end
        end
        
        return response
      end
    end

    namespace 'resource/upload/base64' do
      params do
        requires :kind, type: Integer
        requires :file, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          _resource = decode_base64_image(params[:file])

          _img = Rich::RichFile.new(simplified_type: 'image')
          _file_attrs = _resource
          _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
          # _banner_img.id = Rich::RichFile.last.id + 1
          _img.rich_file = _file_params
          _img.rich_file_file_name = _file_attrs[:filename]

          resource = ::Resource.new(file: _img, status: ::Resource.status[:enabled], kind: params[:kind], user_id: current_user.id)

          if resource.save
            response = { status: 201, message: 'Filed uploaded', content: Entities::Resource.represent(resource) }
          else
            response = { status: 500, message: 'Failed to save file', content: nil }
          end
        end

        return response
      end
    end

    helpers do
      def decode_base64_image(obj_hash)
        file = nil
        if obj_hash.try(:match, %r{^data:(.*?);(.*?),(.*)$})
          image_data = split_base64(obj_hash)
          image_data_string = image_data[:data]
          image_data_binary = Base64.decode64(image_data_string)

          temp_img_file = Tempfile.new("")
          temp_img_file.binmode
          temp_img_file << image_data_binary
          temp_img_file.rewind
          
          img_params = {:filename => "image.#{image_data[:extension]}", :type => image_data[:type], :tempfile => temp_img_file}
          # uploaded_file = ActionDispatch::Http::UploadedFile.new(img_params)

          file = img_params
        end
        return file
      end

      def split_base64(uri_str)
  		  if uri_str.match(%r{^data:(.*?);(.*?),(.*)$})
  		    uri = Hash.new
  		    uri[:type] = $1 # "image/gif"
  		    uri[:encoder] = $2 # "base64"
  		    uri[:data] = $3 # data string
  		    uri[:extension] = $1.split('/')[1] # "gif"
  		    return uri
  		  else
  		    return nil
  		  end
      end

    end

  end
end
