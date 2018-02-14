# frozen_string_literal: true
# frozen_string_literal: true
module V1
  class UserConnections < Grape::API
    include NotificationControllerConcern
    prefix 'api'

    namespace 'users/connections/search' do
      params do
        requires :radius, type: Integer
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :query, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          users = []
          locations = []
          radius = params[:radius]
          page = params[:page]
          limit = params[:limit]
          latitude = current_user.home_address.latitude
          longitude = current_user.home_address.longitude

          # create ignore user list
          ignore_user_list = []
          ignore_user_list << current_user.id
          current_user.connected_to.all.each do |connection|
            if UserConnection.connection_statuses[connection.connection_status] == UserConnection.connection_statuses[:accepted]
              ignore_user_list << connection.action_user_id
            end
          end
          current_user.connected_with.each do |connection|
            if UserConnection.connection_statuses[connection.connection_status] == UserConnection.connection_statuses[:accepted]
              ignore_user_list << connection.user_two_id
            end
          end

          if radius > 0 && latitude == 0.0 && longitude == 0.0
            response = { status: 406, message: 'Please update your profile with your location', content: nil }
          else
            if params[:query].nil?
              if radius > 0
                locations = Address.joins(:user).where("users.deleted_at IS NULL").where().not(users:{:id => ignore_user_list, :role => [User.roles[:guest], User.roles[:super_admin], User.roles[:admin]]}).near([latitude, longitude], radius).order(id: :desc).page(page).per(limit)
              else
                locations = Address.joins(:user).where("users.deleted_at IS NULL").where().not(users:{:id => ignore_user_list, :role => [User.roles[:guest], User.roles[:super_admin]]}).order('users.first_name, users.last_name, users.id').page(page).per(limit)
              end
            else
              query = params[:query].downcase
              if radius > 0
                locations = Address.joins(:user).where().not(users:{:id => ignore_user_list, :role => [User.roles[:guest], User.roles[:super_admin], User.roles[:admin]]}).near([latitude, longitude], radius).where("lower(users.first_name || ' ' || users.last_name) LIKE ?", "%#{query}%").where('users.deleted_at IS NULL').order(id: :desc).page(page).per(limit)
              else
                locations = Address.joins(:user).where().not(users:{:id => ignore_user_list, :role => [User.roles[:guest], User.roles[:super_admin], User.roles[:admin]]}).where("lower(users.first_name || ' ' || users.last_name) LIKE ?", "%#{query}%").where('users.deleted_at IS NULL').order('users.first_name, users.last_name, users.id').page(page).per(limit)
              end
            end
          end

          locations.each do |location|
            users << location.user
          end

          if !users.empty?
            response = {
              status: 200,
              message: "#{users.count} Users found",
              content: Entities::UserConnections::SearchResult.represent(users, current_user: current_user)
            }
          else
            if latitude == 0.0 && longitude == 0.0
              response = { status: 406, message: 'Please update your profile with your location', content: nil }
            else
              response = {status: 200, message: 'No results', content: nil}
            end
          end
          # else
          #   response = { status: 406, message: 'Please update your profile with your location', content: nil }
          # end
        end

        return response
      end
    end

    namespace 'users/search' do
      params do
        requires :radius, type: Integer
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :query, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          users = []
          locations = []
          radius = params[:radius]
          page = params[:page]
          limit = params[:limit]

          # create ignore user list
          ignore_user_list = []
          # ignore_user_list << current_user.id
          current_user.connected_to.all.each do |connection|
            if UserConnection.connection_statuses[connection.connection_status] == UserConnection.connection_statuses[:accepted]
              ignore_user_list << connection.action_user_id
            end
          end
          current_user.connected_with.each do |connection|
            if UserConnection.connection_statuses[connection.connection_status] == UserConnection.connection_statuses[:accepted]
              ignore_user_list << connection.user_two_id
            end
          end

          query = params[:query].downcase
          users = User.where(:id => ignore_user_list, :role => [User.roles[:member]]).where("lower(first_name || ' ' || last_name) LIKE ?", "%#{query}%").where('deleted_at IS NULL').order('first_name, last_name, users.id').page(page).per(limit)

          if !users.empty?
            response = {
              status: 200,
              message: "#{users.count} Users found",
              content: Entities::UserConnections::SearchResult.represent(users, current_user: current_user)
            }
          else
            response = {status: 200, message: 'No results', content: nil}
          end
          # else
          #   response = { status: 406, message: 'Please update your profile with your location', content: nil }
          # end
        end

        return response
      end
    end

    namespace 'users/connected/search' do
      params do
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :query, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          users = []
          locations = []
          page = params[:page]
          limit = params[:limit]
          query = params[:query].downcase

          ignore_user_list = []
          ignore_user_list << current_user.id
          # users = User.joins(:connected_to).joins(:connected_with).where('user_connections.user_one_id = ? or user_connections.user_two_id= ? and user_connections.connection_status = ?',current_user.id,current_user.id,::UserConnection.connection_statuses[:accepted]).where("lower(users.first_name || ' ' || users.last_name) LIKE ?", "%#{params[:query]}%").page(page).per(limit)
          users = User.where().not(users:{:id => ignore_user_list, :role => [User.roles[:guest], User.roles[:super_admin], User.roles[:admin]]}).where("lower(users.first_name || ' ' || users.last_name) LIKE ?", "%#{query}%").where("users.deleted_at IS NULL").order(id: :desc).page(page).per(limit)
          # byebug
            if !users.empty?
              response = {
                status: 200,
                message: "#{users.count} Users found",
                content: Entities::UserConnections::SearchResult.represent(users, current_user: current_user)
              }
            else
              response = {
                status: 200,
                message: 'No results',
                content: nil
              }
            end
        end

        return response
      end
    end

    namespace 'users/connections/:id' do
      # get all connections
      params do
        requires :type, type: Integer, values: 1..4
        requires :page, type: Integer
        requires :limit, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?

          connections = []

          case params[:type]
          when UserConnection.connection_statuses[:pending]
            connections = current_user.pending_connections.joins(:user_requester, :user_requestee).order('users.first_name, users.last_name, users.id').page(params[:page]).per(params[:limit])
            response[:message] = "Pending connections"

          when UserConnection.connection_statuses[:accepted]
            connections = current_user.active_connections.joins(:user_requester, :user_requestee).order('users.first_name, users.last_name, users.id').page(params[:page]).per(params[:limit])
            response[:message] = "Active connections"

          when UserConnection.connection_statuses[:blocked]
            connections = current_user.blocked_connections.joins(:user_requester, :user_requestee).order('users.first_name, users.last_name, users.id').page(params[:page]).per(params[:limit])
            response[:message] = "Blocked connections"
          end

          if !connections.empty?
            response = {
              status: 200,
              message: response[:message],
              content: Entities::UserConnections.represent(connections, current_user: current_user)
            }
          else
            response = {
              status: 200,
              message: 'No connections for user',
              content: nil
            }
          end
        end

        return response
      end

      # make a connection
      params do
        requires :user_id, type: Integer
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?

          user_requestee = User.find_by(id: params[:user_id])
          if !user_requestee.nil?

            if params[:user_id] != current_user.id

              if current_user.connection_status(params[:user_id]).empty?

                connection = UserConnection.new(:user_one_id => current_user.id, :user_two_id => params[:user_id], :connection_status => UserConnection.connection_statuses[:pending], :action_user_id => current_user.id)

                if connection.save

                  # create_notification("Connection request sent to #{user_requestee.first_name} #{user_requestee.last_name}", [current_user.id], Notification.notification_types[:userconnection])
                  create_notification("You have a new connection request from #{current_user.first_name} #{current_user.last_name}", [user_requestee.id], Notification.notification_types[:userconnection])
                  response = {
                    status: 201,
                    message: "Connection request sent to",
                    content: Entities::UserConnections.represent(connection, current_user: current_user)
                  }
                else
                  response = {
                    status: 409,
                    message: "Something went wrong. Failed to make connection request",
                    content: nil
                  }
                end
              else
                response = {
                  status: 406,
                  message: "Connection request already sent",
                  content: nil
                }
              end
            else
              response = {
                status: 406,
                message: "You realise you trying to connect with your self?",
                content: nil
              }
            end
          else
            response = {
              status: 400,
              message: "User not exists",
              content: nil
            }
          end
        end

        return response
      end

      # accepte or reject connection request of someone else's
      params do
        requires :id, type: Integer
        requires :action_type, type: Integer
      end
      put do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?
          # connections = UserConnection.where("user_one_id=(?) AND user_two_id=(?) AND connection_status=(?)", params[:user_id], current_user.id, UserConnection.connection_statuses[:pending])
          connection = UserConnection.find_by(id: params[:id])
          if !connection.nil?

            case params[:action_type]
            when UserConnection.connection_statuses[:accepted]
              updated = connection.update(connection_status: UserConnection.connection_statuses[:accepted])
              if updated
                create_notification("Connection accepted by #{current_user.first_name} #{current_user.last_name}", [connection.user_requester.id], Notification.notification_types[:userconnection])
                response = {
                  status: 200,
                  message: "Connection accepted",
                  content: Entities::UserConnections.represent(connection, current_user: current_user)
                }
              else
                response = {
                  status: 400,
                  message: "Something went wrong. Failed to accept the request",
                  content: nil
                }
              end

            when UserConnection.connection_statuses[:declined]
              # declining a request will delete it
               # create_notification("Connection declined by #{current_user.first_name} #{current_user.last_name}", [connection.user_requestee.id], Notification.notification_types[:userconnection])
               if connection.delete
                response = {
                  status: 200,
                  message: "Connection request declined",
                  content: nil
                }
              else
                response = {
                  status: 409,
                  message: "Something went wrong. Failed to remove connection",
                  content: nil
                }
              end
            end

          else
            response = {
              status: 400,
              message: "Connection doesn't exists",
              content: nil
            }
          end
        end

        return response
      end

      # Remove request or un-firend a connection
      params do
        requires :id, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?

          connections = UserConnection.where("id=?", params[:id])

          if !connections.empty?
            connection = connections.first
            _con_type = connection[:connection_status]
            user = nil
            # byebug

            if connection.user_requestee.id === current_user.id
                user = connection.user_requester
            else
                user = connection.user_requestee
            end

            if connection.destroy!
              result = Entities::User.userPublicMiniTemplate(user, current_user)
              response = {
                status: 200,
                message: "Connection removed",
                content: {user: result}
              }

              case _con_type
              when UserConnection.connection_statuses[:pending]
                response[:message] = "Connection request removed"
              when UserConnection.connection_statuses[:accepted]
                response[:message] = "Connection terminated"
              end
            else
              response = {
                status: 409,
                message: "Something went wrong. Failed to remove connection",
                content: nil
              }
            end
          else
            response = {
              status: 400,
              message: "Connection doesn't exists",
              content: nil
            }
          end
        end

        return response
      end
    end

    namespace 'connections/my/requests' do
      params do
        requires :page, type: Integer
        requires :limit, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?
          connections = current_user.pending_connection_requests.page(params[:page]).per(params[:limit])

          if !connections.empty?
            response = {
              status: 200,
              message: response[:message],
              content: Entities::UserConnections.represent(connections, current_user: current_user)
            }
          else
            response = {
              status: 200,
              message: 'No requests',
              content: nil
            }
          end
        end

        return response
      end
    end

    helpers do
    end

  end
end
