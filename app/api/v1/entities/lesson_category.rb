module V1
  module Entities
    class LessonCategory < Grape::Entity
      expose :id, :title, :description
      expose :badge_icon do |instance, _options|
        instance.badge_icon.nil? ? '' : instance.badge_icon.rich_file.url('original')
      end
      expose :badge_title do |instance, _options|
        instance.badge_title
      end
      expose :percentageComplete do |lc, options|
        return 0 if options[:request]['horseId'].blank?
        horse_id = options[:request]['horseId']
        horse = ::Horse.find(horse_id)
        horse.lesson_category_completed_percentage(lc).round
      end
    end
  end
end
