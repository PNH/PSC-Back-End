class Notification < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :notification_recipient
  has_many :recipients, through: :notification_recipient
  enum notification_type: [:system, :userconnection, :message, :blog_post]

  belongs_to :notifiable, polymorphic: true
end
