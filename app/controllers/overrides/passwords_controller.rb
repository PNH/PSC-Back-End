module Overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController
    def resetviaemail
      # ensure that password params were sent
      unless password_resource_params[:password] && password_resource_params[:password_confirmation]
        return render_update_error_missing_password
      end

      @resource = resource_class.reset_password_by_token(reset_password_token: resource_params[:reset_password_token])
      # @resource = resource_class.where(reset_password_token: resource_params[:reset_password_token]).first
      if @resource && @resource.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        # ensure that user is confirmed
        @resource.skip_confirmation! if @resource.devise_modules.include?(:confirmable) && !@resource.confirmed_at

        # allow user to change password once without current_password
        @resource.allow_password_change = true

        @resource.save!
        # make sure account doesn't use oauth2 provider
        unless @resource.provider == 'email'
          return render_update_error_password_not_required
        end

        if @resource.send(resource_update_method, password_resource_params)
          @resource.allow_password_change = false
        end
        NetsuiteUpdatePasswordJob.perform_later(@resource.id, password_resource_params[:password])

        yield @resource if block_given?

        render json: {
          data: @resource.as_json(except: [
                                    :tokens, :created_at, :updated_at
                                  ], methods: :profilePic)
        }
      else
        render_edit_error
      end
    end

    def update

      result = Netsuite::NetsuiteApi.authenticate(password_resource_params[:email], password_resource_params[:current_password])
      message = ''
        
      unless result[:status] == 1
        case result[:status]
        when -1
          message = "Sorry, but it appears that your membership has become inactive! Maybe you moved or got a new credit card? Either way, we're here to help; please contact your local office as soon as possible and we'll help you reactivate."
        when 0
          message = "Your current password is invalid"
        end

        return  render json: 
        {
          errors: [message]
        }, status: 401
      end
      # make sure user is authorized
      return render_update_error_unauthorized unless @resource

      # make sure account doesn't use oauth2 provider
      unless @resource.provider == 'email'
        return render_update_error_password_not_required
      end

      # ensure that password params were sent
      unless password_resource_params[:password] && password_resource_params[:password_confirmation]
        return render_update_error_missing_password
      end

      if @resource.send(resource_update_method, password_resource_params)
        @resource.allow_password_change = false

        NetsuiteUpdatePasswordJob.perform_later(@resource.id, password_resource_params[:password])

        yield @resource if block_given?
        return render json: 
        {
          success: true,
          data: resource_data,
          message: "Your password has been updated successfully"
        }
      else
        return render_update_error
      end
   end
  end
end
