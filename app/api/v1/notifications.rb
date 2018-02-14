module V1
  class Notifications < Grape::API
    include NotificationControllerConcern
    prefix 'api'
    resource :notifications do
    end

    namespace 'notifications/messages' do
      params do
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :user_id, type: Integer
        optional :commentLimit, type: Integer
        optional :index, type: Integer
      end
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = params[:user_id].nil? ? current_user.id : params[:user_id]
        commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]
        notifyindex = params[:index].nil? ? 0 : params[:index]

          notifications = Notification.joins(:notification_recipient).order(created_at: :desc).where('notification_id > ?',notifyindex).where('notification_recipients.user_id' => user_id).page(params[:page]).per(params[:limit])

          if !notifications.nil? && notifications.count > 0
            return {
              status: 200,
              message: 'Notification found',
              content: Entities::Notification.represent(notifications, current_user: current_user, commnet_limit: commentLimit)
            }
          else
            return {
              status: 404,
              message: 'Notification not found',
              content: nil
            }
          end
      end

      params do
        requires :message, type: String
        requires :user_id, type: Integer
        requires :recipients, type: Array[Integer]
      end
      post do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end

        user = User.find_by_id(params[:user_id])

        if user.nil?
          return {
              status: 404,
              message: 'User not found.',
              content: nil
            }
        end

          # noti = Notification.create(message: params[:message],status: 1, user_id: current_user.id)
          # unless params[:recipients].nil?
          #     params[:recipients].each do |recipient|
          #       reci = User.find_by_id(recipient)
          #       next if reci.nil?
          #       noti.recipients << reci
          #     end
          # end
          result = create_notification(params[:message], params[:recipients], Notification.notification_types.system) #noti.save!
          if result.present?
            return {
              status: 200,
              message: 'Notification added',
              content: Entities::Notification.represent(result, current_user: current_user, commnet_limit: 5)
            }
          else
            return {
              status: 301,
              message: 'Failed to add the notifications',
              content: nil
            }
          end
      end
    end

    namespace 'notifications/messages/:message_id' do

      params do
        requires :message_id, type: Integer
        requires :status, type: Integer
        optional :user_id, type: Integer
      end
      put do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = params[:user_id].nil? ? current_user.id : params[:user_id]

          notifications = Notification.joins(:notification_recipient).where('notification_recipients.notification_id' => params[:message_id]).where('notification_recipients.user_id' => user_id).order(created_at: :desc, id: :asc).page(params[:page]).per(params[:limit])

          if !notifications.empty?
            notification = notifications.first

            success = notification.update(status: params[:status])

            if success
              return {
                status: 200,
                message: 'Notification updated',
                content: Entities::Notification.represent(notification, current_user: current_user, commnet_limit: 5)
              }
            else
              return {
                status: 301,
                message: 'Failed to update the notification',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Notification not found',
              content: nil
            }
          end
      end

      params do
        requires :message_id, type: Integer
        optional :user_id, type: Integer
      end
      delete do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = params[:user_id].nil? ? current_user.id : params[:user_id]

          notifications = Notification.joins(:notification_recipient).where('notification_recipients.notification_id' => params[:message_id]).where('notification_recipients.user_id' => user_id).order(created_at: :desc, id: :asc).page(params[:page]).per(params[:limit])

          if !notifications.empty?

            if notifications.first.destroy!

              return {
                status: 200,
                message: 'Notification deleted',
                content: nil
              }
            else
              return {
                status: 301,
                message: 'Failed to delete notification',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Notification not found',
              content: nil
            }
          end
      end
    end
  end
end
