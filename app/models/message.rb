class Message < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :message_recipient
  has_many :recipients, through: :message_recipient
end
