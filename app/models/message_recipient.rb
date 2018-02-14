# frozen_string_literal: true
class MessageRecipient < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :message
  belongs_to :recipient, class_name: 'User', foreign_key: 'user_id'
end
