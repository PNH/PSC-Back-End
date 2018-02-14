# frozen_string_literal: true
module V1
  module Entities
    class EarnedBadge < Grape::Entity
      expose :level do |level, _option|
        level.id
      end
      expose :badges do |level, _option|
        horse_id = options[:request]['horse_id']
        horse = ::Horse.find(horse_id)
        badges = []
        lesson_categories = ::LessonCategory.joins(savvy: :level)
                                            .where('levels.id = ?', level.id)
                                            .order('savvies.id asc')
                                            .order('lesson_categories.position asc')
        lesson_categories.each do |lc|
          category_completed = HorseBadge.where(horse: horse).where(lesson_category: lc).first
          badges.push(
            'lesson_category' => lc.id,
            'lesson_category_title' => lc.title,
            'savvy_title' => lc.savvy.title,
            'title' => lc.badge_title,
            'logo' => lc.badge_icon.nil? ? '' : lc.badge_icon.rich_file.url('original'),
            'earned_at' => category_completed.nil? ? nil : category_completed.created_at.to_time.to_i
          )
        end
        badges
      end
    end
  end
end
