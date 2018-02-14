module NotificationControllerConcern
  extend ActiveSupport::Concern

  included do
    helpers do
      def create_notification(message, recipients, notification_type)          
        noti = Notification.create(message: message,status: 1, notification_type: notification_type)
          unless recipients.nil?
            recipients.each do |recipient|
              reci = User.find_by_id(recipient)
              next if reci.nil?
              noti.recipients << reci
            end  
          end
         noti.save! ? noti : nil
      end
    end
  end  
end