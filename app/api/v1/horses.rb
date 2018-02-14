# frozen_string_literal: true
module V1
  class Horses < Grape::API
    resource :horses do
      params do
        optional :user_id, type: Integer
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
        user = params[:user_id].nil? ? current_user : User.find_by_id(params[:user_id])
        if user.nil?
          return {
            status: 404,
            message: 'User not found',
            content: ''
          }

        end
          horses = Horse.where(owner: user).order(id: :desc)
          {
            status: 200,
            message: '',
            content: Entities::Horse.represent(horses)
          }
      end

      params do
        requires :id, type: Integer
      end
      delete ':id' do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        ::Horse.where(owner: current_user).find(params[:id]).destroy
        {
          status: 200,
          message: '',
          content: ''
        }
      end

      params do
        requires :name, type: String
        # requires :horsenality, type: Integer, values: Horse.horsenalities.values, allow_blank: true
        # requires :level, type: Integer, values: Level.pluck(:id), allow_blank: true
        # requires :birthday, allow_blank: true, type: String
        # requires :sex, allow_blank: true, type: Integer, values: Horse.sexes.values
        # requires :breed, allow_blank: true, type: String
        # requires :color, allow_blank: true, type: String
        # requires :height, allow_blank: true, type: String
        # requires :weight, allow_blank: true, type: String
        # requires :bio, allow_blank: true, type: String
        # requires :file, type: Rack::Multipart::UploadedFile
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
          horse = ::Horse.find(params[:id])
          unless current_user.horses.exists?(horse)
            return {
              status: 401,
              message: 'Unauthorized, not you horse',
              content: ''
            }
          end
          horse.name = params[:name]
          horse.level = Level.find(params[:level].to_i) unless params[:level].blank?
          horse.bio = params[:bio]
          horse.weight = params[:weight]
          horse.height = params[:height]
          horse.color = params[:color]
          horse.birthday = DateTime.strptime(params[:birthday], '%m/%d/%Y') unless params[:birthday].blank?
          horse.breed = params[:breed]
          horse.sex = Horse.sexes.keys[params[:sex].to_i] unless params[:sex].blank?
          horse.horsenality = Horse.horsenalities.keys[params[:horsenality].to_i] unless params[:horsenality].blank?
          set_profile_pic(horse, params[:file]) unless params[:file].blank?
          horse.save!
          {
            status: 201,
            message: '',
            content: true
          }
        end
      end
    end

    namespace 'horses/meta' do
      get do
        {
          status: 200,
          message: '',
          content: {
            horsenality: ::Horse.horsenalities,
            sex: ::Horse.sexes
          }
        }
      end
    end

    namespace 'horses/:horse_id/badges' do
      params do
        requires :horse_id, type: Integer
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
        horse = ::Horse.find_by_id(params[:horse_id])
        if horse.nil?
          return {
            status: 401,
            message: 'Hourse not found',
            content: ''
          }
        end
        badges = Level.all
        {
          status: 200,
          message: '',
          content: Entities::EarnedBadge.represent(badges, request: request)
        }
      end
    end

    # namespace 'horses/:horse_id/savvies/status2' do
    #   params do
    #     requires :horse_id, type: Integer
    #   end
    #   get do
    #     authenticate_user
    #     unless authenticated?
    #       return {
    #         status: 401,
    #         message: 'Unauthorized',
    #         content: ''
    #       }
    #     end
    #     horse = ::Horse.find_by_id(params[:horse_id])
    #     if horse.nil?
    #       return {
    #         status: 404,
    #         message: 'Hourse not found',
    #         content: ''
    #       }
    #     end
    #     levels = Level.all
    #     {
    #       status: 200,
    #       message: '',
    #       content: Entities::SavvyStatus.represent(levels, request: request)
    #     }
    #   end
    # end

    # namespace 'horses/:horse_id/savvies/status' do
    #   params do
    #     requires :horse_id, type: Integer
    #   end
    #   get do
    #     response = { status: 401, message: 'Unauthorized', content: nil }
    #     # authenticate_user
    #     if true
    #       horse = ::Horse::find_by id: params[:horse_id]
    #       if !horse.nil?
    #         levels = ::Level.where(:deleted_at => nil).order(:id)
    #         savvies = ::Savvy.where(:deleted_at => nil).order(:id)
    #         lesson_categories = ::LessonCategory.where(:deleted_at => nil).order(:position)
    #         lessons = ::Lesson.where(:deleted_at => nil).where.not(:kind => 2)
    #         horse_lessons = horse.horse_lessons.where(:deleted_at => nil, :completed => true)

    #         statues = []
    #         levels.each do |level|
    #           f_savvies = savvies.select { |savvy| savvy.level_id === level.id }

    #           _level_completion = 0
    #           obj_savvies = []
    #           _last_completed_lesson_per_savvy = nil
    #           f_savvies.each do |savvy|

    #             lesson_count = 0
    #             lesson_completed_count = 0
    #             f_lesson_categories = lesson_categories.select { |category| category.savvy_id === savvy.id }
    #             f_lesson_categories.each do |category|
    #               f_lessons = lessons.select { |lesson| lesson.lesson_category_id === category.id }
    #               f_lessons_ids = []
    #               f_lessons.each do |lesson|
    #                 f_lessons_ids << lesson.id
    #               end
    #               # byebug()
    #               f_horse_lessons = horse_lessons.select { |h_lesson| f_lessons_ids.include? h_lesson.lesson_id }
    #               lesson_count += f_lessons.count()
    #               lesson_completed_count += f_horse_lessons.count()
    #               f_horse_lessons.each do |f_lesson|
    #                 _last_completed_lesson_per_savvy = f_lesson.lesson
    #               end
    #             end

    #             if lesson_count > 0
    #               _savvy_completion = (lesson_completed_count * 100/ lesson_count).to_f
    #             else
    #               _savvy_completion = 0
    #             end

    #             obj_savvies << {
    #               id: savvy.id,
    #               title: savvy.title,
    #               percentageComplete: _savvy_completion.to_f
    #             }
    #             _level_completion += _savvy_completion.to_f
    #           end
    #           status  = {
    #             level: {
    #               id: level.id,
    #               title: level.title,
    #               color: level.color,
    #               percentageComplete: _level_completion
    #             },
    #             savvies: obj_savvies,
    #             lastCompletedLessonCategory: !_last_completed_lesson_per_savvy.nil? ? _last_completed_lesson_per_savvy.lesson_category.savvy.id : nil,
    #             isLastCompletedLevel: !_last_completed_lesson_per_savvy.nil? ? true : false,
    #           }

    #           statues << status
    #         end
    #         response = { status:200, message: "", content: statues }
    #       else
    #         response = { status:404, message: "Horse not found", content: nil }
    #       end
    #     end

    #     return response
    #   end
    # end

    namespace 'horses/:horse_id/savvies/status' do
      params do
        requires :horse_id, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        # authenticate_user
        if true
          horse = ::Horse::find_by id: params[:horse_id]
          if !horse.nil?
            levels = ::Level.where(:deleted_at => nil).order(:id)
            savvies = ::Savvy.where(:deleted_at => nil).order(:id)
            lesson_categories = ::LessonCategory.where(:deleted_at => nil).order(:position)
            lessons = ::Lesson.where(:deleted_at => nil).where.not(:kind => 2)
            horse_lessons = horse.horse_lessons.where(:deleted_at => nil, :completed => true)

            statues = []
            levels.each do |level|
              f_savvies = savvies.select { |savvy| savvy.level_id === level.id }

              _level_completion = 0
              obj_savvies = []
              _last_completed_lesson_per_savvy = nil
              f_savvies.each do |savvy|

                lesson_count = 0
                lesson_completed_count = 0
                categories_lessons_count_without_fasttrack = 0
                f_lesson_categories = lesson_categories.select { |category| category.savvy_id === savvy.id }
                f_lesson_categories.each do |category|

                  f_lessons_count_without_fasttrack = 0
                  # byebug
                  f_lessons = lessons.select { |lesson| lesson.lesson_category_id === category.id }
                  f_lessons_ids = []

                  f_lessons.each do |lesson|
                    f_lessons_ids << lesson.id
                    if ::Lesson.kinds[lesson.kind] != ::Lesson.kinds[:fast_track]
                      f_lessons_count_without_fasttrack += 1
                    end
                  end

                  # byebug()
                  f_horse_lessons = horse_lessons.select { |h_lesson| f_lessons_ids.include? h_lesson.lesson_id }

                  f_horse_selfassesments = f_horse_lessons.select { |completed_lesson|
                    ::Lesson.kinds[completed_lesson.lesson.kind] == ::Lesson.kinds[:fast_track]
                  }

                  # byebug
                  lesson_count += f_lessons.count()
                  # byebug

                  if f_horse_selfassesments.empty?
                    lesson_completed_count += f_horse_lessons.count()
                  else
                    lesson_completed_count += f_lessons_count_without_fasttrack
                  end

                  f_horse_lessons.each do |f_lesson|
                    _last_completed_lesson_per_savvy = f_lesson.lesson
                  end

                  categories_lessons_count_without_fasttrack += f_lessons_count_without_fasttrack
                end

                if lesson_count > 0
                  _savvy_completion = (lesson_completed_count * 100/ categories_lessons_count_without_fasttrack).to_f
                else
                  _savvy_completion = 0
                end

                obj_savvies << {
                  id: savvy.id,
                  title: savvy.title,
                  percentageComplete: _savvy_completion.to_f
                }
                _level_completion += _savvy_completion.to_f

                # byebug

              end

              level_percentage_complete = 0
              savvies_on_a_level = level.savvies.count

              unless savvies_on_a_level == 0
                level_percentage_complete = (_level_completion/savvies_on_a_level).to_f
              end

              status  = {
                level: {
                  id: level.id,
                  title: level.title,
                  color: level.color,
                  percentageComplete: level_percentage_complete.round(2)
                },
                savvies: obj_savvies,
                lastCompletedLessonCategory: !_last_completed_lesson_per_savvy.nil? ? _last_completed_lesson_per_savvy.lesson_category.savvy.id : nil,
                isLastCompletedLevel: !_last_completed_lesson_per_savvy.nil? ? true : false,
              }

              statues << status
            end
            response = { status:200, message: "", content: statues }
          else
            response = { status:404, message: "Horse not found", content: nil }
          end
        end

        return response
      end
    end

    namespace 'horses/:horse_id/levels/:level_id/pathway' do
      params do
        requires :horse_id, type: Integer
        requires :level_id, type: Integer
        optional :limit, type: Integer
        optional :fromLessonCategory, type: Integer
        optional :fromIndex, type: Integer
      end
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 404,
            message: 'Unauthorized',
            content: ''
          }
        end
        horse = ::Horse.find_by_id(params[:horse_id])
        if horse.nil?
          return {
            status: 404,
            message: 'Hourse not found',
            content: ''
          }
        end
        level = Level.find(params[:level_id])
        limit = params[:limit] || 10
        from_lc = params[:fromLessonCategory] || 0
        from_index = params[:fromIndex] || 0
        lesson_categories = LessonCategory.joins(savvy: :level)
                                          .where('levels.id = ?', level)
                                          .order('savvies.id asc')
                                          .order('lesson_categories.position asc')
        start_index = from_index
        if from_lc.positive?
          start_index = lesson_categories.find_index { |lc| lc.id.eql?(from_lc) }
        end
        lc_badge = lesson_categories.slice(start_index, limit)
        pg_index = start_index
        lc_badge.each do |lc|
          lc.pagin_index = pg_index
          pg_index += 1
        end
        {
          status: 200,
          message: '',
          content: {
            'start_index' => start_index,
            'limit' => limit,
            'data' => Entities::Pathway.represent(lc_badge, request: request)
          }
        }
      end
    end

    namespace 'horse/:horse/issues' do
      params do
        requires :horse, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          horse = Horse.find_by_id(params[:horse])
          if !horse.nil?
            issues = horse.horse_issues
            content = {
              goal: horse.goal,
              issues: Entities::Horse::HorseIssue.represent(issues)
            }
            response = { status: 200, message: "#{issues.count} issues found", content: content }
          else
            response = { status: 404, message: 'Horse not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :horse, type: Integer
        requires :goal, type: Integer
        requires :issues, type: Array[Integer]
      end
      put do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          horse = Horse.find_by_id(params[:horse])
          if !horse.nil?
            goal = Goal.find_by_id(params[:goal])
            if !goal.nil?
              horse.horse_issues.delete_all
              horse.horse_issues.build(
                params[:issues].map do |id|
                  { issue_id: id }
                end
              )
              horse.goal = goal
              if horse.save!
                issues = horse.horse_issues
                content = {
                  goal: horse.goal,
                  issues: Entities::Horse::HorseIssue.represent(issues)
                }
                response = { status: 205, message: "#{issues.count} issues updated", content: content }
              else
                response = { status: 409, message: 'Failed to update issues', content: nil }
              end
            else
              response = { status: 409, message: 'Goal not found', content: nil }
            end
          else
            response = { status: 404, message: 'Horse not found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'horse/:horse/wall/solutionmap/:id' do
      params do
        requires :horse, type: Integer
        requires :solutionmap_image, type: String, :desc => "Image file."
        # requires :image, type: String
        # requires :privacy, type: Integer
        optional :note, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          horse = Horse.find_by_id(params[:horse])
          if !horse.nil?

            post = ::WallSolutionmapPost.new(horse: horse, note: params[:note])

            # image = Paperclip.io_adapters.for(params[:image])
            # image.original_filename = "file.png"

            solutionmap_image_file = ApiHelper.decode_base64_image(params[:solutionmap_image])

            _img = Rich::RichFile.new(simplified_type: 'image')
            _file_attrs = solutionmap_image_file
            _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
            _img.rich_file = _file_params
            _img.rich_file_file_name = _file_attrs[:filename]
            post.poster = _img

            privacy = Privacysetting.statuses[:privacy_private]

            prv_settings = Privacysetting.find_by user_id: current_user.id, privacy_type: Privacysetting.privacytypes[:wallsetting]
            if !prv_settings.nil?
              privacy = Privacysetting.statuses[prv_settings.status]
            end
            # case privacy
            # when Privacysetting.statuses[:privacy_private]
            #   privacy = Privacysetting.statuses[:privacy_private]
            # when Privacysetting.statuses[:privacy_public]
            #   privacy = Privacysetting.statuses[:privacy_public]
            # end

            wall = ::Wall.new(status: 1, user: current_user, author_id: current_user.id, wallposting: post, privacy: privacy)
            if wall.save!
              response = { status: 201, message: 'Solutionmap shared', content: Entities::Wall.represent(wall, current_user: current_user, commnet_limit: 5) }
            else
              response = { status: 409, message: 'Failed to share post', content: nil }
            end
          else
            response = { status: 404, message: 'Horse not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :horse, type: Integer
        requires :id, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          wall = ::Wall.find_by(:id => params[:id], :user_id => current_user.id)
          if !wall.nil?
            if wall.destroy!
              response = { status: 200, message: 'Wall post removed', content: nil }
            else
              response = { status: 409, message: 'Failed to remove wall post', content: nil }
            end
          else
            response = { status: 404, message: 'Wall post not found', content: nil }
          end
        end

        return response
      end
    end

    helpers do
      def set_profile_pic(horse, file_attrs)
        profile_img = Rich::RichFile.new(simplified_type: 'image')
        file_params = Rack::Multipart::UploadedFile.new file_attrs[:tempfile].path, file_attrs[:type]
        profile_img.rich_file = file_params
        horse.picture = profile_img
      end

      def decode_base64_image
      if image_data && content_type && original_filename
        decoded_data = Base64.decode64(image_data)

        data = StringIO.new(decoded_data)
        data.class_eval do
          attr_accessor :content_type, :original_filename
        end

        data.content_type = content_type
        data.original_filename = File.basename(original_filename)

        self.image = data
      end
    end
    end
  end
end
