# frozen_string_literal: true
class HorseBadge < ActiveRecord::Base
  belongs_to :horse
  belongs_to :lesson_category
end
