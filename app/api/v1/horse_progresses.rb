module V1
  class HorseProgresses < Grape::API

    namespace 'horse/:horse/progress/:id' do
      params do
        requires :horse, type: Integer
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :commentLimit, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          page = params[:page]
          limit = params[:limit]
          commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]

          walls = []
          horse = ::Horse.find_by(:id => params[:horse])
          if !horse.nil?
            if horse.user_id == current_user.id
              walls = Wall.includes(:horse_progress).where(horse_progresses: {:horse_id => params[:horse]}).order('walls.created_at desc, horse_progresses.id').page(page).per(limit)
            else
              walls = Wall.includes(:horse_progress).where(walls: {:privacy => Privacysetting.statuses[:privacy_public]}, horse_progresses: {:horse_id => params[:horse]}).order('walls.created_at desc, horse_progresses.id').page(page).per(limit)
            end

            response = { status: 200, message: "#{walls.count} posts found", content: Entities::Wall.represent(walls, current_user: current_user, commnet_limit: commentLimit) }
          else
            response = { status: 404, message: 'Horse not found', content: nil }
          end

        end

        return response
      end

      params do
        requires :horse, type: Integer
        requires :savvies, type: JSON do
          requires :savvy, type: Integer
          requires :level, type: Integer
          requires :time, type: Integer
        end
        optional :privacy, type: Integer
        optional :note, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          horse = ::Horse.find_by(:id => params[:horse], :user_id => current_user.id)
          if !horse.nil?

            logs = []
            params[:savvies].each do |savvy|
              logs << ::HorseProgressLog.new(
                :savvy_id => savvy.savvy,
                :level_id => savvy.level,
                :time => savvy.time
              )
            end

            progress = ::HorseProgress.new(note: params[:note], horse_progress_logs: logs, horse: horse)

            # privacy = Privacysetting.statuses[:privacy_private]
            # case params[:privacy]
            # when Privacysetting.statuses[:privacy_private]
            #   privacy = Privacysetting.statuses[:privacy_private]
            # when Privacysetting.statuses[:privacy_public]
            #   privacy = Privacysetting.statuses[:privacy_public]
            # end

            privacy = params[:privacy].nil? ? current_user.wall_privacy : params[:privacy]

            wall = ::Wall.new(
              user_id: current_user.id,
              author_id: current_user.id,
              status: 1,
              privacy: privacy,
              wallposting: progress
            )

            if wall.save!
              response = { status: 201, message: 'Progress added', content: Entities::Wall.represent(wall, current_user: current_user, commnet_limit: 5) }
            else
              response = { status: 409, message: 'Failed to add progress', content: nil }
            end
          else
            response = { status: 404, message: 'Horse not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :id, type: Integer
        requires :horse, type: Integer
        requires :savvies, type: JSON do
          requires :savvy, type: Integer
          requires :level, type: Integer
          requires :time, type: Integer
        end
        optional :privacy, type: Integer
        optional :note, type: String
      end
      put do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          wall = ::Wall.find_by(:id => params[:id], :user_id => current_user.id)
          if !wall.nil?

            progress = wall.wallposting
            progress.horse_progress_logs.delete_all
            logs = []
            params[:savvies].each do |savvy|
              logs << ::HorseProgressLog.new(
                :savvy_id => savvy.savvy,
                :level_id => savvy.level,
                :time => savvy.time
              )
            end

            progress.horse_progress_logs = logs
            progress.note = params[:note]

            privacy = Privacysetting.statuses[:privacy_private]
            case params[:privacy]
            when Privacysetting.statuses[:privacy_private]
              privacy = Privacysetting.statuses[:privacy_private]
            when Privacysetting.statuses[:privacy_public]
              privacy = Privacysetting.statuses[:privacy_public]
            end

            wall.privacy = params[:privacy].nil? ? current_user.wall_privacy : params[:privacy]

            if wall.save! && progress.save!
              response = { status: 200, message: 'Progress updated', content: Entities::Wall.represent(wall, current_user: current_user, commnet_limit: 5) }
            else
              response = { status: 409, message: 'Progress update fail', content: nil }
            end
          else
            response = { status: 404, message: 'Wall post not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :id, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          wall = ::Wall.find_by(:id => params[:id])
          if !wall.nil?
            if wall.author_id == current_user.id || wall.user_id == current_user.id
              if wall.destroy!
                response = { status: 200, message: 'Wall post removed', content: nil }
              else
                response = { status: 409, message: 'Failed to remove wall post', content: nil }
              end
            else
              response = { status: 403, message: 'Action not allowed', content: nil }
            end
          else
            response = { status: 404, message: 'Wall post not found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'horse/:horse/progress/archives/:id' do
      params do
        requires :horse, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          horse = ::Horse.find_by(:id => params[:horse], :user_id => current_user.id)
          if !horse.nil?
            yearly_archives = Wall.includes(:horse_progress).where(horse_progresses: {:horse_id => params[:horse]}).group_by{ |w| w.created_at.year }
            full_archives = []

            yearly_archives.sort.reverse.each do |year, archives|
              months = []
              archives.group_by { |t| t.created_at.month }.each do |month, archive|
                months << {:name =>  month, :count => archive.count}
              end
              full_archives << {:name =>  year, :count => months }
            end

            response = { status: 200, message: 'Horse archives', content: full_archives }
          else
            response = { status: 404, message: 'Horse not found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'horse/:horse/progress/archives/:year/:month' do
      params do
        requires :horse, type: Integer
        requires :year, type: Integer
        requires :month, type: Integer
        optional :commentLimit, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          horse = ::Horse.find_by(:id => params[:horse], :user_id => current_user.id)
          if !horse.nil?
            commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]
            datetime = DateTime.new(params[:year], params[:month], 1)
            walls = Wall.includes(:horse_progress).where(horse_progresses: {:horse_id => params[:horse]}).where(:created_at => (datetime.beginning_of_month..datetime.end_of_month)).order('walls.created_at desc')
            response = { status: 200, message: "#{walls.count} posts found", content: Entities::Wall.represent(walls, current_user: current_user, commnet_limit: commentLimit) }
          else
            response = { status: 404, message: 'Horse not found', content: nil }
          end
        end

        return response
      end
    end

  end
end
