# frozen_string_literal: true
module V1
  module Entities
    class Pathway < Grape::Entity
      expose :lessonCategory do |lc, _option|
        lc.id
      end
      expose :title
      expose :pagin_index
      expose :description
      expose :savvy do |lc|
        {
          'id' => lc.savvy.id,
          'title' => lc.savvy.title
        }
      end
      expose :badge_icon do |instance, _options|
        instance.badge_icon.nil? ? '' : instance.badge_icon.rich_file.url('original')
      end
      expose :percentageComplete do |lc, options|
        horse_id = options[:request]['horse_id']
        horse = ::Horse.find(horse_id)
        horse.lesson_category_completed_percentage(lc).round
      end
      expose :lastComplete do |lc, options|
        horse_id = options[:request]['horse_id']
        horse = ::Horse.find(horse_id)
        hl = HorseLesson.where(horse: horse).joins(lesson: :lesson_category)
                        .where(completed: true)
                        .where('lessons.lesson_category_id = ?', lc.id)
                        .last
        hl.nil? ? nil : hl.lesson.id
      end
    end
  end
end
