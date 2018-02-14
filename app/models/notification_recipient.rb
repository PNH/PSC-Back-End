# frozen_string_literal: true
class NotificationRecipient < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :notification
  belongs_to :recipient, class_name: 'User', foreign_key: 'user_id'
end
