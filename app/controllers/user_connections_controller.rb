class UserConnectionsController < InheritedResources::Base

  private

    def user_connection_params
      params.require(:user_connection).permit()
    end
end

