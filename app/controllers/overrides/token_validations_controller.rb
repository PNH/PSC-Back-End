
module Overrides
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
    def render_validate_token_success

      # if (cookies["CloudFront-Signature"].blank?)
      #   AwsSigner.cookie_signer(cookies)
      # end

      render json: {
        success: false,
        data: @resource.as_json(except: [
                                  :tokens, :created_at, :updated_at
                                ], methods: [:profilePic,:unread_messages_count, :wall_posts_count, :connections_count])
      }
    end
  end
end
