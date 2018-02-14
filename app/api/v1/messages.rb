module V1
  class Messages < Grape::API
    prefix 'api'
    include NotificationControllerConcern
    resource :messages do
    end

    namespace 'messages/users' do
      params do
        optional :user_id, type: Integer
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
        messages = Message.joins(:message_recipient).order(created_at: :desc).where('messages.user_id = ? or message_recipients.user_id = ?',user_id,user_id)
        users = []
        messages.each do |message|
            users << message.user unless message.user.id == current_user.id
            message.recipients.each do |user|
              users << user unless user.id == current_user.id
            end
        end
        users = users.uniq { |u| u.id }
          result = []
          if !users.nil? && users.count > 0
            users.each do |user|
                result << Entities::User.userPublicMiniTemplate(user, current_user)
            end

            return {
              status: 200,
              message: 'User found',
              content: result
            }
          else
            return {
              status: 404,
              message: 'User not found',
              content: nil
            }
          end
      end

      params do
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

         messages = Message.joins(:message_recipient).where('messages.user_id = ? or messages.user_id = ? ',params[:user_id], current_user.id).where('message_recipients.user_id = ? or message_recipients.user_id = ?',params[:user_id], current_user.id)

          if !messages.empty?

            if messages.each do |msg|
               msg.destroy!
            end

              return {
                status: 200,
                message: 'Message deleted',
                content: nil
              }
            else
              return {
                status: 301,
                message: 'Failed to delete message',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Message not found',
              content: nil
            }
          end
      end
    end

    namespace 'messages' do
      params do
        requires :page, type: Integer
        requires :limit, type: Integer
        requires :recipient, type: Integer
        optional :user_id, type: Integer
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
        messageindex = params[:index].nil? ? 0 : params[:index]

          messages = Message.joins(:message_recipient).order(created_at: :desc).where('message_id > ?',messageindex).where('messages.user_id = ? or messages.user_id = ? ',user_id, params[:recipient]).where('message_recipients.user_id = ? or message_recipients.user_id = ?',user_id, params[:recipient]).page(params[:page]).per(params[:limit])

          if !messages.nil? && messages.count > 0

            # mark as read
            messages.each do |message|
              message.message_recipient.each do |recipient|
                message.status = true
                if recipient.user_id === current_user.id
                  recipient.status = true
                  recipient.save
                end
                message.save
              end
            end

            return {
              status: 200,
              message: 'Message found',
              content: Entities::Message.represent(messages, current_user: current_user)
            }
          else
            return {
              status: 404,
              message: 'Message not found',
              content: nil
            }
          end
      end

      params do
        requires :message, type: String
        requires :recipients, type: Array[Integer]
        optional :user_id, type: Integer
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

        user_id = params[:user_id].nil? ? current_user.id : params[:user_id]
        user = User.find_by_id(user_id)

        if user.nil?
          return {
              status: 404,
              message: 'User not found.',
              content: nil
            }
        end

          msg = Message.create(content: params[:message],status: 0, user_id: user.id)
          unless params[:recipients].nil?
              params[:recipients].each do |recipient|
                reci = User.find_by_id(recipient)
                next if reci.nil? || recipient == user_id
                msg.recipients << reci
              end
          end

          if msg.recipients.count == 0
            return {
                status: 404,
                message: 'Message recipient not valid',
                content: nil
              }
          end

          if msg.save!

            msg.recipients.each do |reci|
              create_notification("You have a new message from #{user.first_name} #{user.last_name}", [reci.id], Notification.notification_types[:message])
            end

            return {
              status: 200,
              message: 'Message added',
              content: Entities::Message.represent(msg, current_user: current_user, commnet_limit: 5)
            }
          else
            return {
              status: 301,
              message: 'Failed to add the messages',
              content: nil
            }
          end
      end
    end

    namespace 'messages/:message_id' do

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

          messages = Message.joins(:message_recipient).where('message_recipients.message_id' => params[:message_id]).where('message_recipients.user_id' => user_id)

          if !messages.empty?
            message = messages.first

            mrs = MessageRecipient.where(user_id: user_id, message_id: message.id)
            unless mrs.empty?
              mrs.first.status = params[:status]
              success = mrs.first.save!
            end

            if success
              return {
                status: 200,
                message: 'Message updated',
                content: Entities::Message.represent(message, current_user: current_user, commnet_limit: 5)
              }
            else
              return {
                status: 301,
                message: 'Failed to update the message',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Message not found',
              content: nil
            }
          end
      end

      params do
        optional :user_id, type: Integer
        requires :message_id, type: Integer
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

         messages = Message.joins(:message_recipient).order(created_at: :desc).where('messages.user_id = ? or message_recipients.user_id = ?',user_id,user_id)

          if !messages.empty?

            if messages.first.destroy!

              return {
                status: 200,
                message: 'Message deleted',
                content: nil
              }
            else
              return {
                status: 301,
                message: 'Failed to delete message',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Message not found',
              content: nil
            }
          end
      end
    end
  end
end
