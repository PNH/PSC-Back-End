# frozen_string_literal: true
class Testimonial < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :user # only for active admin

  validates :user_id, :message, presence: true
end
