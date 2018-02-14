# frozen_string_literal: true
module V1
  class LessonCategories < Grape::API
    prefix 'api'

    namespace 'lesson_categories/:lesson_category_id' do
      resource :lessons do
        params do
          requires :lesson_category_id, type: Integer
        end
        get do
          authenticate_user
          unless authenticated?
            return {
              status: 401,
              message: 'Unauthorized',
              content: ''
            }
          end
          lessons = ::Lesson.where(lesson_category_id: params[:lesson_category_id])
                            .where(status: true)
                            .where.not(kind: Lesson.kinds[:sample])
                            .order('lessons.position asc')
          {
            status: 200,
            message: '',
            content: Entities::Lesson.represent(lessons)
          }
        end
      end
    end
  end
end
