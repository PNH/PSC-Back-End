# frozen_string_literal: true
module V1
  class Lessons < Grape::API
    prefix 'api'
    resource :lessons do
      params do
        requires :id, type: Integer
        requires :horseId, type: Integer
      end
      route_param :id do
        get do
          authenticate_user
          unless authenticated?
            return {
              status: 401,
              message: 'Unauthorized',
              content: ''
            }
          end
          horse_id = params[:horseId]
          horse = ::Horse.find(horse_id)
          unless current_user.horses.exists?(horse)
            return {
              status: 401,
              message: 'Unauthorized, not you horse',
              content: ''
            }
          end
          lesson = Lesson.find(params[:id])
          {
            status: 200,
            message: '',
            content: Entities::LessonDetail.represent(lesson, request: request, current_user: current_user)
          }
        end
      end

      params do
        requires :id, type: Integer
        requires :horseId, type: Integer
        requires :status, type: Boolean
      end
      route_param :id do
        post do
          authenticate_user
          unless authenticated?
            return {
              status: 401,
              message: 'Unauthorized',
              content: ''
            }
          end
          lesson = Lesson.find(params[:id])
          horse = ::Horse.find(params[:horseId])
          unless current_user.horses.exists?(horse)
            return {
              status: 401,
              message: 'Unauthorized, not you horse',
              content: ''
            }
          end
          r = false
          r = horse.completed(lesson) if params[:status]
          {
            status: 200,
            message: '',
            content: r
          }
        end
      end
    end
  end
end
