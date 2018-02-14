# frozen_string_literal: true
class HorseLesson < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :horse
  belongs_to :lesson

  after_save :check_badge_earned

  private

  def check_badge_earned
    lesson_category = lesson.lesson_category
    already_earned = horse.horse_badges.exists?(lesson_category: lesson_category)
    return true if already_earned # earned badge not revoke even new lesson add to category
    if horse.lesson_category_completed_percentage(lesson_category).to_i.eql?(100)
      horse.horse_badges.create!(lesson_category: lesson_category)
    end
  end
end
