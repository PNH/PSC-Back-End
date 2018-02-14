# frozen_string_literal: true
class ContentBlock < ActiveRecord::Base
  acts_as_paranoid

  has_many :blocks
  validates :slug, presence: true

  accepts_nested_attributes_for :blocks, allow_destroy: true
end
