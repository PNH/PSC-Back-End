module V1
  class Walls < Grape::API
    prefix 'api'
    resource :walls do
    end

    namespace 'wall/filtertypes' do
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          filtertypes = Wall.select(:wallposting_type).map(&:wallposting_type).uniq
          if !filtertypes.empty?
            _types = []
            filtertypes.each do |filter|
              _types << filter
            end
            response = { status: 200, message: "#{_types.count} filters found", content: _types }
          else
            response = { status: 200, message: "No filters found", content: nil }
          end
        end

        return response
      end
    end

    namespace 'wall/public' do
      params do
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :commentLimit, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]
          posts = Wall.where('privacy=? or privacy is null', Privacysetting.statuses[:privacy_public]).order(created_at: :desc, id: :desc).page(params[:page]).per(params[:limit])
          if !posts.empty?
            response = { status: 200, message: "#{posts.count} Posts found", content: Entities::Wall.represent(posts, current_user: current_user, commnet_limit: commentLimit) }
          else
            response = { status: 200, message: 'No public posts found', content: nil }
          end
        end
        return response
      end

      params do
        requires :type, type: String
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :filters, type: JSON do
          requires :type, type: String
        end
        optional :commentLimit, type: Integer
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          page = params[:page]
          limit = params[:limit]
          commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]
          filterObjs = []
          if !params[:filters].nil?
            params[:filters].each do |filter|
              filterObjs << filter[:type]
            end
          end

          connctions_ids = []
          current_user.active_connections.pluck(:user_one_id, :user_two_id).each { |connection|
            connctions_ids << connection[0]
            connctions_ids << connection[1]
          }

          # 0-all, 1-connected, 2-instructor, 3-staff
          case params[:type]
          when 'all'
            if filterObjs.empty?

              posts = ::Wall.where("privacy IS NULL
                      OR
                      privacy=#{Privacysetting.statuses[:privacy_public]}
                      OR
                      ((author_id=#{current_user.id} OR user_id=#{current_user.id}) AND privacy=#{Privacysetting.statuses[:privacy_private]})
                      OR
                      (author_id IN (?) AND privacy=#{Privacysetting.statuses[:privacy_connected]})", connctions_ids)
                      .uniq
                      .order(created_at: :desc, id: :desc)
                      .page(page)
                      .per(limit)
            else
              # posts = ::Wall.where('privacy=? or privacy is null or user_id=?', Privacysetting.statuses[:privacy_public], current_user.id).where(:wallposting_type => filterObjs).order(created_at: :desc, id: :desc).page(page).per(limit)

              posts = ::Wall.where("privacy IS NULL
                      OR
                      privacy=#{Privacysetting.statuses[:privacy_public]}
                      OR
                      ((author_id=#{current_user.id} OR user_id=#{current_user.id}) AND privacy=#{Privacysetting.statuses[:privacy_private]})
                      OR
                      (author_id IN (?) AND privacy=#{Privacysetting.statuses[:privacy_connected]})", connctions_ids)
                      .where(:wallposting_type => filterObjs)
                      .uniq
                      .order(created_at: :desc, id: :desc)
                      .page(page)
                      .per(limit)

              # posts = ::Wall.joins("INNER JOIN user_connections ON (walls.author_id=user_connections.user_one_id or walls.author_id=user_connections.user_two_id) and (user_connections.user_one_id=#{current_user.id} and user_connections.connection_status=#{UserConnection.connection_statuses[:accepted]}
              # or
              # user_connections.user_two_id=#{current_user.id} and user_connections.connection_status=#{UserConnection.connection_statuses[:accepted]})
              # and
              # privacy=#{Privacysetting.statuses[:privacy_connected]}
              # or
              # privacy=#{Privacysetting.statuses[:privacy_public]} or privacy is null or user_id=#{current_user.id}").where(:wallposting_type => filterObjs).uniq.order(created_at: :desc, id: :desc).page(page).per(limit)
              # NL_LOGGER.info "#{Time.now.to_f} - end get all post no filters"

            end

          when 'connected'
            # select walls.* from walls, user_connections where (walls.user_id=user_connections.user_one_id or walls.user_id=user_connections.user_two_id) and user_connections.user_one_id=496;
            # posts = ::Wall.includes(:user_connections).where('privacy=? or privacy is null', Privacysetting.statuses[:privacy_public]).where("user_connections.user_one_id=#{current_user.id} OR user_connections.user_two_id=#{current_user.id}").order(created_at: :desc, id: :desc).page(page).per(limit)

            if filterObjs.empty?

              posts = ::Wall.where("author_id IN (?) AND (privacy=#{Privacysetting.statuses[:privacy_connected]} OR privacy=#{Privacysetting.statuses[:privacy_public]})", connctions_ids)
                      .where.not(author_id: current_user.id)
                      .uniq
                      .order(created_at: :desc, id: :desc)
                      .page(page)
                      .per(limit)
            else

              posts = ::Wall.where("author_id IN (?) AND (privacy=#{Privacysetting.statuses[:privacy_connected]} OR privacy=#{Privacysetting.statuses[:privacy_public]})", connctions_ids)
                      .where(:wallposting_type => filterObjs)
                      .where.not(author_id: current_user.id)
                      .uniq
                      .order(created_at: :desc, id: :desc)
                      .page(page)
                      .per(limit)

              # posts = ::Wall.joins("INNER JOIN user_connections ON (walls.author_id=user_connections.user_one_id or walls.author_id=user_connections.user_two_id) and (user_connections.user_one_id=#{current_user.id} and user_connections.connection_status=#{UserConnection.connection_statuses[:accepted]}
              # or
              # user_connections.user_two_id=#{current_user.id} and user_connections.connection_status=#{UserConnection.connection_statuses[:accepted]}) and (privacy=#{Privacysetting.statuses[:privacy_connected]} or privacy=#{Privacysetting.statuses[:privacy_public]})").where(:wallposting_type => filterObjs).where.not(author_id: current_user.id).uniq.order(created_at: :desc, id: :desc).page(page).per(limit)
            end
          when 'instructor'
            #
            if filterObjs.empty?
              posts = ::Wall.joins(:user).where('privacy=? or privacy is null', Privacysetting.statuses[:privacy_public]).where("users.is_instructor=true").order(created_at: :desc, id: :desc).page(page).per(limit)
            else
              posts = ::Wall.joins(:user).where('privacy=? or privacy is null', Privacysetting.statuses[:privacy_public]).where("users.is_instructor=true").where(:wallposting_type => filterObjs).order(created_at: :desc, id: :desc).page(page).per(limit)
            end
          when 'staff'
            #
            if filterObjs.empty?
              posts = ::Wall.joins(:user).where('privacy=? or privacy is null', Privacysetting.statuses[:privacy_public]).where("users.is_staff_member=true").order(created_at: :desc, id: :desc).page(page).per(limit)
            else
              posts = ::Wall.joins(:user).where('privacy=? or privacy is null', Privacysetting.statuses[:privacy_public]).where("users.is_staff_member=true").where(:wallposting_type => filterObjs).order(created_at: :desc, id: :desc).page(page).per(limit)
            end
          end

          if !posts.empty?
            response = { status: 200, message: "#{posts.count} Posts found", content: Entities::Wall.represent(posts, current_user: current_user, commnet_limit: commentLimit) }
          else
            response = { status: 200, message: 'No public posts found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'walls/:user_id/posts' do
      params do

        requires :page, type: Integer
        requires :limit, type: Integer
        optional :user_id, type: Integer
        optional :commentLimit, type: Integer
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
        user_id = params[:user_id].nil? ? current_user.id : params[:user_id]
        commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]

        if user_id == current_user.id
          posts = Wall.where(user_id: user_id).order(created_at: :desc, id: :desc).page(params[:page]).per(params[:limit])
        else
          if current_user.is_connected(user_id)
            posts = Wall.where(user_id: user_id).where('privacy =? or privacy =? or privacy is null', Privacysetting.statuses[:privacy_connected], Privacysetting.statuses[:privacy_public]).order(created_at: :desc, id: :desc).page(params[:page]).per(params[:limit])
          else
            posts = Wall.where(user_id: user_id).where('privacy =? or privacy is null', Privacysetting.statuses[:privacy_public]).order(created_at: :desc, id: :desc).page(params[:page]).per(params[:limit])
          end
        end

          if !posts.nil? && posts.count > 0
            posts.each do |post|
              likes = post.wall_post_like.count
              my_likes = WallPostLike.where wall_id: params[:wall_id], user_id: user_id

            end
            return {
              status: 200,
              message: 'Wall posts found',
              content: Entities::Wall.represent(posts, current_user: current_user, commnet_limit: commentLimit)
            }
          else
            return {
              status: 404,
              message: 'Walls posts not found',
              content: nil
            }
          end
      end

      params do
        requires :content, type: String
        requires :user_id, type: Integer
        optional :privacy, type: Integer
      end
      post do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end

        user = User.find_by_id(params[:user_id])

        if user.nil?
          return {
              status: 404,
              message: 'User not found.',
              content: nil
            }
        end
          privacy = params[:privacy].nil? ? current_user.wall_privacy : params[:privacy]
          wp = WallPost.create(content: params[:content],status: 1, user_id: current_user.id)
          post = Wall.new(status: 1, user: user, author_id: current_user.id, wallposting: wp, privacy: privacy)

          error_msg = nil;
          if post.save

            if !params[:images].nil?
              params[:images].each do |image|
                next if image.nil?

                _banner_img = Rich::RichFile.new(simplified_type: 'image')
                # _banner_img.id = Rich::RichFile.last.id + 1
                _file_attrs = image[:image]
                _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
                _banner_img.rich_file = _file_params

                if _file_attrs[:type].include? 'image'
                  post_attachment = WallPostAttachment.new(wall_id: post.id, resource: _banner_img, status: 1)
                  post_attachment.save
                else
                  error_msg = "One or more invalid attachment/s found."
                end
              end
            end


            return {
              status: 200,
              message: error_msg.nil? ? 'Post added' : error_msg,
              content: Entities::Wall.represent(post, current_user: current_user, commnet_limit: 5)
            }
          else
            return {
              status: 301,
              message: 'Failed to add the post',
              content: nil
            }
          end
      end
    end

    namespace 'walls/:user_id/posts/:post_id' do

      params do
        requires :post_id, type: Integer
        requires :content, type: String
        optional :privacy, type: Integer
      end
      put do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id

          posts = Wall.where id: params[:post_id]
          if !posts.empty? && (posts.first.user_id = user_id || posts.first.author_id = user_id || current_user.admin?  || current_user.super_admin? )
            post = posts.first
            privacy = params[:privacy].nil? ? current_user.wall_privacy : params[:privacy]
            case post.wallposting_type
            when 'WallPost'
              post.update(privacy: privacy)
              success = post.wallposting.update(content: params[:content])
            end

            if success
              return {
                status: 200,
                message: 'Post updated',
                content: Entities::Wall.represent(post, current_user: current_user, commnet_limit: 5)
              }
            else
              return {
                status: 301,
                message: 'Failed to update the post',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Post not found',
              content: nil
            }
          end
      end

      params do
        requires :user_id, type: Integer
        requires :post_id, type: Integer
      end
      delete do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id

          posts = Wall.where id: params[:post_id]
          if !posts.empty?
            post = posts.first
            unless post.user_id == user_id || post.author_id == user_id || current_user.admin? || current_user.super_admin?
              return {
                status: 301,
                message: 'Action not permitted',
                content: nil
              }
            end

            if post.destroy

              return {
                status: 200,
                message: 'Post deleted',
                content: nil
              }
            else
              return {
                status: 301,
                message: 'Failed to delete post',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Post not found',
              content: nil
            }
          end
      end
    end

    namespace 'walls/:user_id/posts/:post_id/attachment/:id' do
      params do
        requires :post_id, type: Integer
        requires :attachment, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
      end
      post do
        response = nil
        authenticate_user
        unless authenticated?
          response = {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
        posts = Wall.where id: params[:post_id]

        if !posts.empty?
          post = posts.first

          _banner_img = Rich::RichFile.new(simplified_type: 'image')
          _file_attrs = params[:attachment]
          _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
          # _banner_img.id = Rich::RichFile.last.id + 1
          _banner_img.rich_file = _file_params
          _banner_img.rich_file_file_name = _file_attrs[:filename]

          post_attachment = WallPostAttachment.new(wall_id: post.id, resource: _banner_img, status: 1)
          if post_attachment.save

            # post.likes = post.wall_post_like.count
            # my_likes = WallPostLike.where wall_id: params[:wall_id], user_id: user_id
            # if !my_likes.empty?
            #   post.liked = true
            # else
            #   post.liked = false
            # end

            # if post.author.id === user_id
            #   post.isowner = true
            # else
            #   post.isowner = false
            # end

            response = {
              status: 200,
              message: 'Attachment added',
              content: Entities::Wall.represent(post, current_user: current_user, commnet_limit: 5)
            }
          else

            # post_attachment.resource.id = Rich::RichFile.last.id + 1
            if post_attachment.save
                response = {
                status: 200,
                message: 'Attachment added',
                content: Entities::Wall.represent(post, current_user: current_user, commnet_limit: 5)
              }
            else
              response = {
                status: 400,
                message: 'Failed to add attachment',
                content: nil
              }
            end
          end
        else
          response = {
            status: 404,
            message: 'Post not found',
            content: nil
          }
        end
        return response
      end

      params do
        requires :post_id, type: Integer
        requires :id, type: Integer
      end
      delete do
        response = nil
        authenticate_user
        unless authenticated?
          response = {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id

        posts = Wall.where id: params[:post_id]

        if !posts.empty?
          post = posts.first
          attachments = WallPostAttachment.where id: params[:id], wall_id: params[:post_id]
          if !attachments.empty?

            attachment = attachments.first

            if attachment.delete

              response = {
                status: 200,
                message: 'Attachment removed from post',
                content: Entities::Wall.represent(post, current_user: current_user, commnet_limit: 5)
              }
            else
              response = {
                status: 417,
                message: 'Failed to remove attachment',
                content: nil
              }
            end
          else
            response = {
              status: 410,
              message: 'Failed to find attachment',
              content: nil
            }
          end
        else
          response = {
            status: 410,
            message: 'Failed to find the post',
            content: nil
          }
        end
        return response
      end
    end

    namespace 'walls/:user_id/posts/:post_id/likes' do
      params do
        requires :user_id, type: Integer
        requires :post_id, type: Integer
      end
      post do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
        # user_id = 110

          exlikes = WallPostLike.where user_id: user_id, wall_id: params[:post_id]
          if exlikes.nil? || exlikes.empty?
            like = WallPostLike.new(user_id: user_id, wall_id: params[:post_id], status: 1)
            if like.save
              response = {
                status: 200,
                message: 'Post liked',
                content: Entities::Wall::WallPostLikes.represent(like)
              }
            else
              response = {
                status: 200,
                message: 'Failed to like the post',
                content: nil
              }
            end
          else
            response = {
              status: 200,
              message: 'You already liked this post',
              content: Entities::Wall::WallPostLikes.represent(exlikes)
            }
          end
        return response
      end

      params do
        requires :user_id, type: Integer
        requires :post_id, type: Integer
      end
      delete do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id

          exlikes = WallPostLike.where user_id: user_id, wall_id: params[:post_id]
          if !exlikes.nil? || !exlikes.empty?
            success = false
            exlikes.each do |like|
              success = like.delete
            end
            if success
              response = {
                status: 200,
                message: 'Post like deleted',
                content: nil
              }
            else
              response = {
                status: 200,
                message: 'Failed to unlike the post',
                content: nil
              }
            end
          else
            response = {
              status: 404,
              message: 'You haven\'t like this post yet',
              content: nil
            }
          end
        return response
      end
    end

    namespace 'walls/:user_id/posts/:post_id/comments' do
      params do
        requires :post_id, type: Integer
        requires :user_id, type: Integer
        requires :page, type: Integer
        requires :limit, type: Integer
      end
      get do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id

          comments = (::WallPostComment.where wall_id: params[:post_id]).order(created_at: :desc, id: :desc).page(params[:page]).per(params[:limit])
          if !comments.empty?
            response = {
              status: 200,
              message: 'Comments found',
              content: Entities::Wall::WallPostComments.represent(comments,current_user: current_user)
            }
          else
            response = {
              status: 200,
              message: 'No comments yet',
              content: nil
            }
          end
        return response
      end

      params do
        requires :post_id, type: Integer
        requires :comment, type: String
        optional :parentId, type: Integer
      end
      post do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id

        wallpost = Wall.find_by_id(params[:post_id])
        unless wallpost.nil?
          comment = ::WallPostComment.new(user_id: user_id, wall_id: params[:post_id], comment: params[:comment], parent_id: params[:parentId])
          if comment.save

            response = {
              status: 200,
              message: 'Post comment added',
              content: Entities::Wall::WallPostComments.represent(comment,current_user: current_user)
            }
          else
            response = {
              status: 301,
              message: 'Failed to add the post comment',
              content: nil
            }
          end
        else
          response = {
            status: 400,
            message: 'Post not found',
            content: nil
          }
        end
        return response
      end
    end

    namespace 'walls/:user_id/posts/:post_id/comments/:id' do

      params do
        requires :id, type: Integer
        requires :post_id, type: Integer
        requires :comment, type: String
        optional :parentId, type: Integer
      end
      put do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
          comments = ::WallPostComment.where id: params[:id]
          if !comments.empty? && (comments.first.user_id == user_id || current_user.admin? || current_user.super_admin?)
            comment = comments.first
            success = comment.update(comment: params[:comment])
            if success

              response = {
                status: 200,
                message: 'Comment updated',
                content: Entities::Wall::WallPostComments.represent(comment,current_user: current_user)
              }
            else
              response = {
                status: 200,
                message: 'Failed to update updated',
                content: nil
              }
            end
          else
            response = {
              status: 404,
              message: 'Comment not found',
              content: nil
            }
          end
        return response
      end

     params do
        requires :id, type: Integer
      end
      delete do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
          comments = ::WallPostComment.where id: params[:id]
          unless comments.empty?
          comment = comments.first
            unless comment.wall.user_id == user_id || comment.user_id == user_id || current_user.admin? || current_user.super_admin?
              return {
                status: 301,
                message: 'Action not permitted',
                content: nil
              }
            end

            if comment.delete

              response = {
                status: 200,
                message: 'Comment deleted',
                content: nil
              }
            else
              response = {
                status: 200,
                message: 'Failed to delete the comment',
                content: nil
              }
            end
          else
            response = {
              status: 404,
              message: 'Comment not found',
              content: nil
            }
          end
        return response
      end
    end
  end
end
