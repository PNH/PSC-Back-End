module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    def create
      # Check

      result = fetch_user?(resource_params)
      unless result[:status] == 1

        case result[:status]
        when -1
          message = "Sorry, but it appears that your membership has become inactive! Maybe you moved or got a new credit card? Either way, we're here to help; please contact your local office as soon as possible and we'll help you reactivate."
        when 0
          message = "Invalid login credentials. Please try again."
        end

        return  render json: 
        {
          errors: [message]
        }, status: 401
      end
      
      @resource = result[:content]

      if @resource && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render json: {
          data: @resource.as_json(except: [
                                    :tokens, :created_at, :updated_at
                                  ], methods: [:profilePic, :membership_level, :unread_messages_count, :wall_posts_count, :connections_count])
        }
      elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
      end
    end

    def fetch_user?(resource_params)
      result = Netsuite::NetsuiteApi.authenticate(resource_params[:email], resource_params[:password])
      if result[:status] == 0
         result = fetch_admin?(resource_params)
      end
      result
    end

    def fetch_admin?(resource_params)
      found_member = User.find_by_email(resource_params[:email])
      if found_member.present? && found_member.valid_password?(resource_params[:password]) && (found_member.admin? || found_member.super_admin?)
        return {status: 1, content: found_member}
      else
        return {status: 0, content: nil}
      end
    end

  end
end
