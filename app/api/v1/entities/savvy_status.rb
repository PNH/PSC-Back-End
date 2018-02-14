# frozen_string_literal: true
module V1
  module Entities
    class SavvyStatus < Grape::Entity
      expose :level do |level, _option|
        horse_id = options[:request]['horse_id']
        horse = ::Horse.find(horse_id)
        {
          'id' => level.id,
          'title' => level.title,
          'color' => level.color,
          'percentageComplete' => horse.level_completed_percentage(level).round
        }
      end
      expose :savvies do |level, options|
        horse_id = options[:request]['horse_id']
        horse = ::Horse.find(horse_id)
        level.savvies.map do |savvy|
          {
            'id' => savvy.id,
            'title' => savvy.title,
            'percentageComplete' => horse.savvy_completed_percentage(savvy).round
          }
        end
      end
      expose :lastCompletedLessonCategory do |level, options|
        horse_id = options[:request]['horse_id']
        horse = ::Horse.find(horse_id)
        last_completed_lesson_category(level, horse)
      end
      expose :isLastCompletedLevel do |level, options|
        horse_id = options[:request]['horse_id']
        horse = ::Horse.find(horse_id)
        is_the_last_completed_level(level, horse)
      end

      private

      def last_completed_lesson_category(level, horse)
        levellesson = HorseLesson.joins(lesson: [{ lesson_category: [savvy: :level] }])
                                 .where(horse: horse)
                                 .where('levels.id = ?', level.id)
                                 .order(id: :desc)
                                 .first
        levellesson.nil? ? nil : levellesson.id
      end

      def is_the_last_completed_level(level, horse)
        hl = HorseLesson.where(horse: horse).order(id: :desc).first
        return false if hl.nil?
        hl.lesson.lesson_category.savvy.level.eql?(level)
      end
    end
  end
end
