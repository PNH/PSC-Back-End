# frozen_string_literal: true
module V1
  class Levels < Grape::API
    prefix 'api'
    resource :levels do
      get do
        levels = Level.all
        {
          status: 200,
          message: '',
          content: Entities::Level.represent(levels)
        }
      end
    end

    namespace 'levels/:level_id/savvies' do
      params do
        requires :level_id, type: Integer
      end
      get do
        savvies = Savvy.where(level_id: params[:level_id])
        {
          status: 200,
          message: '',
          content: Entities::Savvy.represent(savvies)
        }
      end
    end

    # namespace 'levels/:level_id/lesson_categories2' do
    #   params do
    #     requires :level_id, type: Integer
    #     requires :horseId, type: Integer
    #   end
    #   get do
    #     lcs = LessonCategory.joins(:savvy)
    #                         .order('savvies.id asc')
    #                         .order('lesson_categories.position asc')
    #                         .where('savvies.level_id = ?', params[:level_id])
    #     {
    #       status: 200,
    #       message: '',
    #       content: Entities::LessonCategory.represent(lcs, request: request)
    #     }
    #   end
    # end

    namespace 'levels/:level_id/lesson_categories' do
      params do
        requires :level_id, type: Integer
        requires :horseId, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        # authenticate_user
        if true
          horse = ::Horse::find_by id: params[:horseId]
          if !horse.nil?
            levels = ::Level.where(:id => params[:level_id], :deleted_at => nil).order(:id)
            savvies = ::Savvy.where(:level_id => params[:level_id], :deleted_at => nil).order(:id)
            lesson_categories = ::LessonCategory.where(:deleted_at => nil).order(:position)
            lessons = ::Lesson.where(:deleted_at => nil).where.not(:kind => ::Lesson.kinds[:sample])
            horse_lessons = horse.horse_lessons.where(:deleted_at => nil, :completed => true)

            statues = []
            levels.each do |level|
              f_savvies = savvies.select { |savvy| savvy.level_id === level.id }

              _level_completion = 0
              obj_savvies = []
              _last_completed_lesson_per_savvy = nil
              f_savvies.each do |savvy|

                f_lesson_categories = lesson_categories.select { |category| category.savvy_id === savvy.id }
                f_lesson_categories.each do |category|
                  f_lessons = lessons.select { |lesson| lesson.lesson_category_id === category.id }
                  f_lessons_ids = []
                  _fasttrack_lesson = nil
                  _fasttrack_lesson_completed = false
                  f_lessons.each do |lesson|
                    f_lessons_ids << lesson.id
                    if ::Lesson.kinds[lesson.kind] === ::Lesson.kinds[:fast_track]
                      _fasttrack_lesson = lesson
                    end
                  end
                  # byebug()
                  f_horse_lessons = horse_lessons.select { |h_lesson| f_lessons_ids.include? h_lesson.lesson_id }
                  f_horse_lessons.each do |lesson|
                    if !_fasttrack_lesson.nil? && lesson.lesson_id === _fasttrack_lesson.id
                      _fasttrack_lesson_completed = true
                    end
                  end
                  # byebug()
                  _category_completion = 0
                  if f_lessons.count() > 0
                    if !_fasttrack_lesson.nil?
                      _category_completion = (f_horse_lessons.count() * 100/ (f_lessons.count()-1)).to_f
                    else
                      _category_completion = (f_horse_lessons.count() * 100/ f_lessons.count()).to_f
                    end
                  end

                  if _fasttrack_lesson_completed
                    _category_completion = 100
                  end

                  statues << {
                    id: category.id,
                    title: category.title,
                    description: category.description,
                    badge_icon: category.badge_icon.nil? ? '' : category.badge_icon.rich_file.url('original'),
                    badge_title: category.badge_title,
                    percentageComplete: _category_completion.to_f
                  }
                end
              end
            end
            response = { status:200, message: "", content: statues }
          else
            response = { status:404, message: "Horse not found", content: nil }
          end
        end

        return response
      end
    end

    namespace 'levels/:level_id/savvies/:savvy_id/lesson_categories' do
      params do
        requires :level_id, type: Integer
        requires :savvy_id, type: Integer
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
        lc = LessonCategory.where(savvy_id: params[:savvy_id])
        {
          status: 200,
          message: '',
          content: Entities::LessonCategory.represent(lc)
        }
      end
    end

    namespace 'levels/:level_id/checklist' do
      params do
        requires :level_id, type: Integer
      end
      get do
        # authenticate_user
        # unless authenticated?
        #   return {
        #     status: 401,
        #     message: 'Unauthorized',
        #     content: ''
        #   }
        # end
        lc = LevelChecklist.find_by level_id: params[:level_id]

        if !lc.nil?
          return {
            status: 200,
            message: 'Checklist found',
            content: Entities::LevelChecklist.represent(lc)
          }
        else
          return {
            status: 404,
            message: 'Checklist item not found',
            content: nil
          }
        end
      end
    end

    namespace 'levels/checklistsall' do
      get do
        # authenticate_user
        # unless authenticated?
        #   return {
        #     status: 401,
        #     message: 'Unauthorized',
        #     content: ''
        #   }
        # end
        lc = LevelChecklist.all

        if !lc.nil? && lc.count > 0
          return {
            status: 200,
            message: 'Checklist found',
            content: Entities::LevelChecklist.represent(lc)
          }
        else
          return {
            status: 200,
            message: 'Checklist items not found',
            content: nil
          }
        end
      end
    end

  end
end
