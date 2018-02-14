module V1
  class ForumPosts < Grape::API
    prefix 'api'
    resource :forum_posts do
    end

    namespace 'forum-topics/:forum_id/forum-posts' do
      params do
        requires :forum_id, type: Integer
        requires :page, type: Integer
        requires :limit, type: Integer
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
        user_id = current_user.id
        commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]
        moderators = ForumModerator.where forum_id: params[:forum_id], user_id: user_id
        members = ForumMember.where forum_id: params[:forum_id], user_id: user_id

          posts = ForumPost.where(forum_topic: params[:forum_id]).order(:created_at, id: :asc).page(params[:page]).per(params[:limit])

          if !posts.nil? && posts.count > 0
            posts.each do |post|
              post.likes = post.forum_post_like.count
              my_likes = ForumPostLike.where forum_id: params[:forum_id], forum_post_id: post.id, user_id: user_id
              if !my_likes.empty?
                post.liked = true
              else
                post.liked = false
              end

              if post.user.present? && post.user.id === user_id
                post.isowner = true
              else
                post.isowner = false
              end

              post.commentcount = post.forum_post_comment.count

            end
            return {
              status: 200,
              message: 'Forum posts found',
              content: Entities::ForumPost.represent(posts, current_user: current_user, commnet_limit: commentLimit)
            }
          else
            return {
              status: 404,
              message: 'Forums posts not found',
              content: nil
            }
          end
      end

      params do
        requires :forum_id, type: Integer
        requires :content, type: String
        # optional :images, type: Array do
        #   requires :image, :type => Rack::Multipart::UploadedFile, :desc => "Profile pictures."
        # end
        # optional :images, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
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
        user_id = current_user.id
        forumtopic = ForumTopic.find_by_id(params[:forum_id])
        unless  forumtopic.nil?

          post = ForumPost.new(content: params[:content], forum_id: params[:forum_id], status: 1, user_id: user_id)
          error_msg = nil;
          if post.save

            if !params[:images].nil?
              params[:images].each do |image|
                next if image.nil?

                _banner_img = Rich::RichFile.new(simplified_type: 'image')
                _file_attrs = image[:image]
                _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
                _banner_img.rich_file = _file_params

                if _file_attrs[:type].include? 'image'
                  post_attachment = ForumPostAttachment.new(forum_post_id: post.id, resource: _banner_img, status: 1)
                  post_attachment.save
                else
                  error_msg = "One or more invalid attachment/s found."
                end
              end
            end

            forumtopic.touch

            return {
              status: 200,
              message: error_msg.nil? ? 'Post added' : error_msg,
              content: Entities::ForumPost.represent(post, current_user: current_user, commnet_limit: 5)
            }
          else
            return {
              status: 301,
              message: 'Failed to add the post',
              content: nil
            }
          end
        else
          return {
            status: 400,
            message: 'Topic not found',
            content: nil
          }
        end
      end

      params do
        requires :forum_id, type: Integer
        requires :id, type: Integer
        requires :content, type: String
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
        # user_id = 110
        moderators = ForumModerator.where forum_id: params[:forum_id], user_id: user_id
        members = ForumMember.where forum_id: params[:forum_id], user_id: user_id
        # if !members.empty? || !moderators.empty?
        if current_user.admin? || current_user.super_admin?
          posts = ForumPost.where id: params[:id]
        else
          posts = ForumPost.where id: params[:id], user_id: user_id
        end

          if !posts.empty?
            post = posts.first
            success = post.update(content: params[:content])
            if success
              forumTopic = ForumTopic.find params[:forum_id]
              forumTopic.touch unless forumTopic.nil?

              return {
                status: 200,
                message: 'Post updated',
                content: Entities::ForumPost.represent(post, current_user: current_user, commnet_limit: 5)
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
        # else
        #   return {
        #     status: 400,
        #     message: 'You are not a forum member',
        #     content: nil
        #   }
        # end
      end
    end

    namespace 'forum-topics/:forum_id/forum-posts/:post_id' do
      params do
        requires :forum_id, type: Integer
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
        # user_id = 110
        # moderators = ForumModerator.where forum_id: params[:forum_id], user_id: user_id
        # members = ForumMember.where forum_id: params[:forum_id], user_id: user_id
        # if !members.empty? || !moderators.empty?
          posts = ForumPost.where id: params[:post_id]
          if !posts.empty?
            post = posts.first
            unless post.user_id == user_id || current_user.admin? || current_user.super_admin?
              return {
                status: 301,
                message: 'Action not permitted',
                content: nil
              }
            end

            if post.destroy!
              forumTopic = ForumTopic.find params[:forum_id]
              forumTopic.touch unless forumTopic.nil?

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
        # else
        #   return {
        #     status: 400,
        #     message: 'You are not a forum member',
        #     content: nil
        #   }
        # end
      end
    end

    namespace 'forum-posts/:post_id/attachment/:id' do
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

        if current_user.admin? || current_user.super_admin?
          posts = ForumPost.where id: params[:post_id]
        else
          posts = ForumPost.where id: params[:post_id], user_id: user_id
        end


        if !posts.empty?
          post = posts.first

          _banner_img = Rich::RichFile.new
          _file_attrs = params[:attachment]
          _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
          # _banner_img.id = Rich::RichFile.last.id + 1
          _banner_img.rich_file = _file_params

          post_attachment = ForumPostAttachment.new(forum_post_id: post.id, resource: _banner_img, status: 1)
          if post_attachment.save

            post.likes = post.forum_post_like.count
            my_likes = ForumPostLike.where forum_id: params[:forum_id], forum_post_id: post.id, user_id: user_id
            if !my_likes.empty?
              post.liked = true
            else
              post.liked = false
            end

            if post.user.id === user_id
              post.isowner = true
            else
              post.isowner = false
            end

            post.commentcount = post.forum_post_comment.count

            response = {
              status: 200,
              message: 'Attachment added',
              content: Entities::ForumPost.represent(post, current_user: current_user, commnet_limit: 5)
            }
          else

            # post_attachment.resource.id = Rich::RichFile.last.id + 1
            if post_attachment.save
                response = {
                  status: 200,
                  message: 'Attachment added',
                  content: Entities::ForumPost.represent(post, current_user: current_user, commnet_limit: 5)
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
        if current_user.admin? || current_user.super_admin?
          posts = ForumPost.where id: params[:post_id]
        else
          posts = ForumPost.where id: params[:post_id], user_id: user_id
        end


        if !posts.empty?
          post = posts.first
          attachments = ForumPostAttachment.where id: params[:id], forum_post_id: params[:post_id]
          if !attachments.empty?

            attachment = attachments.first

            if attachment.delete

              post.likes = post.forum_post_like.count
              my_likes = ForumPostLike.where forum_id: params[:forum_id], forum_post_id: post.id, user_id: user_id
              if !my_likes.empty?
                post.liked = true
              else
                post.liked = false
              end

              if post.user.id === user_id
                post.isowner = true
              else
                post.isowner = false
              end

              post.commentcount = post.forum_post_comment.count

              response = {
                status: 200,
                message: 'Attachment removed from post',
                content: Entities::ForumPost.represent(post, current_user: current_user, commnet_limit: 5)
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

    namespace 'forum-posts/:post_id/forum-comments' do
      params do
        requires :post_id, type: Integer
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

          comments = (ForumPostComment.where forum_post_id: params[:post_id]).order(:created_at, id: :asc).page(params[:page]).per(params[:limit])
          if !comments.empty?
            comments.each do |comment|
              if comment.user.present? && comment.user.id === user_id
                comment.isowner = true
                next
              else
                comment.isowner = false
              end
            end

            response = {
              status: 200,
              message: 'Comments found',
              content: Entities::ForumTopic::ForumPostComment.represent(comments,current_user: current_user)
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

        forumpost = ForumPost.find_by_id(params[:post_id])
        unless forumpost.nil?
          comment = ForumPostComment.new(user_id: user_id, forum_post_id: params[:post_id], comment: params[:comment], parent_id: params[:parentId])
          if comment.save
            forumtopic = forumpost.forum_topic
            forumtopic.touch

            response = {
              status: 200,
              message: 'Post comment added',
              content: Entities::ForumTopic::ForumPostComment.represent(comment,current_user: current_user)
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
        if current_user.admin? || current_user.super_admin?
          comments = ForumPostComment.where id: params[:id]
        else
          comments = ForumPostComment.where id: params[:id], user_id: user_id
        end

          if !comments.empty?
            comment = comments.first
            success = comment.update(comment: params[:comment])
            if success
              forumtopic = comment.forum_post.forum_topic
              forumtopic.touch

              response = {
                status: 200,
                message: 'Comment updated',
                content: Entities::ForumTopic::ForumPostComment.represent(comment,current_user: current_user)
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
    end

    namespace 'forum-posts/:post_id/forum-comments/:comment_id' do
     params do
        requires :comment_id, type: Integer
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
        if current_user.admin? || current_user.super_admin?
          comments = ForumPostComment.where id: params[:comment_id]
        else
          comments = ForumPostComment.where id: params[:comment_id], user_id: user_id
        end

          if !comments.empty?
            comment = comments.first
            forum_topic = comment.forum_post.forum_topic
            if comment.delete

              forum_topic.touch

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

    namespace 'posts/:post/comments/:comment/attachments/:id' do
      params do
        requires :post, type: Integer
        requires :comment, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          if !::ForumPost.find_by(id: params[:post]).nil?
            _comment = ::ForumPostComment.find_by(forum_post_id: params[:post], id: params[:comment])
            if !_comment.nil?
              _attachments = _comment.forum_post_comment_attachments
              response = { status: 200, message: "#{_attachments.count} attachments found", content: V1::Entities::ForumPost::ForumPostCommentAttachments.represent(_attachments) }
            else
              response = { status: 404, message: 'Forum post comment not found', content: nil }
            end
          else
            response = { status: 404, message: 'Forum post not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :post, type: Integer
        requires :comment, type: Integer
        requires :attachment, :type => Rack::Multipart::UploadedFile, :desc => "File."
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          if !::ForumPost.find_by(id: params[:post]).nil?
            _comment = ::ForumPostComment.find_by(forum_post_id: params[:post], id: params[:comment])
            if !_comment.nil?
              attachment = ::ForumPostCommentAttachment.new(user_id: current_user.id, forum_post_id: params[:post], forum_post_comment_id: params[:comment])

              _file = Rich::RichFile.new
              _file_attrs = params[:attachment]
              _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
              _file.rich_file = _file_params
              attachment.resource = _file

              if attachment.save!
                # response = { status: 201, message: 'Attachment added', content: V1::Entities::ForumPost::ForumPostCommentAttachments.represent(attachment) }
                response = { status: 201, message: 'Attachment added', content: V1::Entities::ForumTopic::ForumPostComment.represent(_comment,current_user: current_user) }
              else
                response = { status: 500, message: 'Failed to add the attachment', content: nil }
              end
            else
              response = { status: 404, message: 'Forum post commnet not found', content: nil }
            end
          else
            response = { status: 404, message: 'Forum post not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :id, type: Integer
        requires :post, type: Integer
        requires :comment, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          if !::ForumPost.find_by(id: params[:post]).nil?
            _comment = ::ForumPostComment.find_by(forum_post_id: params[:post], id: params[:comment])
            if !_comment.nil?
              _attachment = ::ForumPostCommentAttachment.find_by(forum_post_id: params[:post], forum_post_comment_id: params[:comment], id: params[:id])
              if !_attachment.nil?
                if _attachment.delete
                  response = { status: 200, message: 'Forum post commnet attachment removed', content: nil }
                else
                  response = { status: 500, message: 'Failed to remove forum post commnet attachment', content: nil }
                end
              else
                response = { status: 404, message: 'Forum post commnet attachment not found', content: nil }
              end
            else
              response = { status: 404, message: 'Forum post comment not found', content: nil }
            end
          else
            response = { status: 404, message: 'Forum post not found', content: nil }
          end
        end

        return response
      end

    end
  end
end
