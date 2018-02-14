# frozen_string_literal: true
class LessonCategory < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list scope: [:savvy_id]
  attr_accessor :pagin_index

  belongs_to :savvy
  has_many :lessons, dependent: :destroy
  has_many :horse_badges, dependent: :destroy
  belongs_to :badge_icon, class_name: 'Rich::RichFile', foreign_key: 'badge_icon_id'

  validates :title, presence: true

  def fast_track_lesson
    lessons.where(kind: ::Lesson.kinds.values_at(:fast_track)).first
  end
end
