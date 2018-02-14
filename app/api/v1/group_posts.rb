module V1
  class GroupPosts < Grape::API
    prefix 'api'
    resource :group_posts do
    end

    namespace 'groups/:group_id/posts/:id' do
      params do
        requires :group_id, type: Integer
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
        # user_id = 110
        moderators = GroupModerator.where group_id: params[:group_id], user_id: user_id
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty? || !moderators.empty?

          posts = GroupPost.where(group_id: params[:group_id]).order(created_at: :desc, id: :desc).page(params[:page]).per(params[:limit])

          if !posts.nil? && posts.count > 0
            posts.each do |post|
              post.likes = post.group_post_like.count
              my_likes = GroupPostLike.where group_id: params[:group_id], group_post_id: post.id, user_id: user_id
              if !my_likes.empty?
                post.liked = true
              else
                post.liked = false
              end

              if !post.user.nil? && post.user.id === user_id
                post.isowner = true
              else
                post.isowner = false
              end

              post.commentcount = post.group_post_comment.count

            end
            return {
              status: 200,
              message: "#{posts.count} group posts found",
              content: Entities::Group::GroupPost.represent(posts, current_user: current_user, commnet_limit: commentLimit)
            }
          else
            return {
              status: 404,
              message: 'Groups posts not found',
              content: nil
            }
          end
        else
          return {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end

      end

      params do
        requires :group_id, type: Integer
        optional :content, type: String
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
        # user_id = 110
        moderators = GroupModerator.where group_id: params[:group_id], user_id: user_id
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty? || !moderators.empty?
          _content = params[:content].nil? ? nil : params[:content]
          post = GroupPost.new(content: _content, group_id: params[:group_id], status: 1, user_id: user_id)
          if post.save
            group = Group.find params[:group_id]
            group.touch

            return {
              status: 200,
              message: 'Post added',
              content: Entities::Group::GroupPost.represent(post, current_user: current_user, commnet_limit: 5)
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
            message: 'You are not a group member',
            content: nil
          }
        end
      end

      params do
        requires :group_id, type: Integer
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
        moderators = GroupModerator.where group_id: params[:group_id], user_id: user_id
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty? || !moderators.empty?
          posts = GroupPost.where id: params[:id], user_id: user_id
          if !posts.empty?
            post = posts.first
            success = post.update(content: params[:content])
            if success
              group = Group.find params[:group_id]
              group.touch

              return {
                status: 200,
                message: 'Post updated',
                content: Entities::Group::GroupPost.represent(post, current_user: current_user, commnet_limit: 5)
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
        else
          return {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end
      end

      params do
        requires :group_id, type: Integer
        requires :id, type: Integer
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
        moderators = GroupModerator.where group_id: params[:group_id], user_id: user_id
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty? || !moderators.empty?
          posts = GroupPost.where id: params[:id], user_id: user_id
          if !posts.empty?
            post = posts.first
            if post.destroy
              group = Group.find params[:group_id]
              group.touch

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
        else
          return {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end
      end

    end

    namespace 'groups/:group_id/posts/:id/like' do
      params do
        requires :group_id, type: Integer
        requires :id, type: String
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
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          exlikes = GroupPostLike.where group_id: params[:group_id], group_post_id: params[:id], user_id: user_id
          if exlikes.nil? || exlikes.empty?
            like = GroupPostLike.new(group_id: params[:group_id], group_post_id: params[:id], user_id: user_id, status: 1)
            if like.save
              group = Group.find params[:group_id]
              group.touch

              response = {
                status: 200,
                message: 'Post liked',
                content: Entities::Group::GroupPostLike.represent(like)
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
              content: Entities::Group::GroupPostLike.represent(exlikes)
            }
          end
        else
          response = {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end
        return response
      end

      params do
        requires :group_id, type: Integer
        requires :id, type: String
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
        # user_id = 110
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          exlikes = GroupPostLike.where group_id: params[:group_id], group_post_id: params[:id], user_id: user_id
          if !exlikes.nil? || !exlikes.empty?
            success = false
            exlikes.each do |like|
              success = like.delete
            end
            if success
              group = Group.find params[:group_id]
              group.touch

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
        else
          response = {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end
        return response
      end
    end

    namespace 'groups/:group_id/posts/:post_id/comment/:id' do
      params do
        requires :group_id, type: Integer
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
        # user_id = 110
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          comments = GroupPostComment.where(group_post_id: params[:post_id]).order(created_at: :desc, id: :desc).page(params[:page]).per(params[:limit])
          if !comments.empty?
            comments.each do |comment|
              if !comment.user.nil? && comment.user.id === user_id
                comment.isowner = true
                next
              else
                comment.isowner = false
              end
            end

            response = {
              status: 200,
              message: 'Comments found',
              content: Entities::Group::GroupPostComment.represent(comments)
            }
          else
            response = {
              status: 200,
              message: 'No comments yet',
              content: nil
            }
          end
        else
          response = {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end
        return response
      end

      params do
        requires :group_id, type: Integer
        requires :post_id, type: Integer
        requires :comment, type: String
        requires :parentId, type: Integer
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
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          comment = GroupPostComment.new(user_id: user_id, group_post_id: params[:post_id], comment: params[:comment], parent_id: params[:parentId])
          if comment.save
            group = Group.find params[:group_id]
            group.touch

            comment.isowner = true

            response = {
              status: 200,
              message: 'Post comment added',
              content: Entities::Group::GroupPostComment.represent(comment)
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
            message: 'You are not a group member',
            content: nil
          }
        end
        return response
      end

      params do
        requires :id, type: Integer
        requires :group_id, type: Integer
        requires :post_id, type: Integer
        requires :comment, type: String
        requires :parentId, type: Integer
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
        # user_id = 110
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          comments = GroupPostComment.where id: params[:id], user_id: user_id
          if !comments.empty?
            comment = comments.first
            success = comment.update(comment: params[:comment])
            if success
              group = Group.find params[:group_id]
              group.touch

              comment.isowner = true

              response = {
                status: 200,
                message: 'Comment updated',
                content: Entities::Group::GroupPostComment.represent(comment)
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
        else
          response = {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end
        return response
      end

      params do
        requires :id, type: Integer
        requires :group_id, type: Integer
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
        # user_id = 110
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          comments = GroupPostComment.where id: params[:id], user_id: user_id
          if !comments.empty?
            comment = comments.first
            if comment.delete
              group = Group.find params[:group_id]
              group.touch

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
        else
          response = {
            status: 400,
            message: 'You are not a group member',
            content: nil
          }
        end
        return response
      end
    end

    namespace 'groups/:group_id/posts/:post_id/resource/:id' do

      params do
        requires :group_id, type: Integer
        requires :post_id, type: Integer
      end
      get do
        authenticate_user
        unless authenticated?
          response = {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
          return response
        end
        user_id = current_user.id
        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          posts = GroupPost.where id: params[:post_id], user_id: user_id
          if !posts.nil? && !posts.empty?
            post = posts.first
            attachments = post.group_post_attachment
            response = {
              status: 200,
              message: 'Attachments found',
              content: Entities::Group::GroupPostAttachment.represent(attachments)
            }
          else
            response = {
              status: 404,
              message: 'Post not found',
              content: nil
            }
          end
        else
          response = {
            status: 400,
            message: 'You are not a member of this Group',
            content: nil
          }
        end

        return response
      end

      params do
        requires :group_id, type: Integer
        requires :post_id, type: Integer
        requires :document, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
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
        # user_id = 110

        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          posts = GroupPost.where id: params[:post_id], user_id: user_id
          if !posts.empty?
            post = posts.first
            _resource = Rich::RichFile.new
            _file_attrs = params[:document]
            _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
            # _resource.id = Rich::RichFile.last.id + 1
            _resource.rich_file = _file_params

            attachment = GroupPostAttachment.new(group_post_id:params[:post_id], status:1)
            attachment.resource = _resource
            success = attachment.save!

            if success
              group = Group.find params[:group_id]
              group.touch

              # content: Entities::Group::GroupPostAttachment.represent(attachment)
              response = {
                status: 200,
                message: 'Resource added to the Post',
                content: Entities::Group::GroupPost.represent(post, current_user: current_user, commnet_limit: 5)
              }
            else
              response = {
                status: 400,
                message: 'Failed to add resource',
                content: nil
              }
            end
          else
            response = {
              status: 404,
              message: 'Post not found',
              content: nil
            }
          end
        else
          response = {
            status: 400,
            message: 'You are not a member',
            content: nil
          }
        end
        return response
      end

      params do
        requires :group_id, type: Integer
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
        # user_id = 110

        members = GroupMember.where group_id: params[:group_id], user_id: user_id
        if !members.empty?
          attachment = GroupPostAttachment.find params[:id]
          if !attachment.nil?
            success = attachment.delete
            if success
              group = Group.find params[:group_id]
              group.touch

              response = {
                status: 200,
                message: 'Attachment removed',
                content: nil
              }
            else
              response = {
                status: 400,
                message: 'Failed to remove resource',
                content: nil
              }
            end
          else
            response = {
              status: 404,
              message: 'Attachment not found',
              content: nil
            }
          end
        else
          response = {
            status: 400,
            message: 'You are not a member',
            content: nil
          }
        end
        return response
      end

    end

    namespace 'groups/:group/posts/:post/comments/:comment/attachments/:id' do
      params do
        requires :post, type: Integer
        requires :comment, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          if !::Group.find_by(id: params[:group]).nil?
            if !::GroupPost.find_by(id: params[:post]).nil?
              _comment = ::GroupPostComment.find_by(group_post_id: params[:post], id: params[:comment])
              if !_comment.nil?
                _attachments = _comment.group_post_comment_attachments
                response = { status: 200, message: "#{_attachments.count} attachments found", content: V1::Entities::ForumPost::ForumPostCommentAttachments.represent(_attachments) }
              else
                response = { status: 404, message: 'Group post comment not found', content: nil }
              end
            else
              response = { status: 404, message: 'Group post not found', content: nil }
            end
          else
            response = { status: 404, message: 'Group not found', content: nil }
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
          if !::Group.find_by(id: params[:group]).nil?
            if !::GroupPost.find_by(id: params[:post]).nil?
              _comment = ::GroupPostComment.find_by(group_post_id: params[:post], id: params[:comment])
              if !_comment.nil?
                attachment = ::GroupPostCommentAttachment.new(user_id: current_user.id, group_post_id: params[:post], group_post_comment_id: params[:comment])

                _file = Rich::RichFile.new
                _file_attrs = params[:attachment]
                _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
                _file.rich_file = _file_params
                attachment.resource = _file

                if attachment.save!
                  # response = { status: 201, message: 'Attachment added', content: V1::Entities::ForumPost::ForumPostCommentAttachments.represent(attachment) }
                  response = { status: 201, message: 'Attachment added', content: V1::Entities::Group::GroupPostComment.represent(_comment) }
                else
                  response = { status: 500, message: 'Failed to add the attachment', content: nil }
                end
              else
                response = { status: 404, message: 'Group post commnet not found', content: nil }
              end
            else
              response = { status: 404, message: 'Group post not found', content: nil }
            end
          else
            response = { status: 404, message: 'Group not found', content: nil }
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
          if !::Group.find_by(id: params[:group]).nil?
            if !::GroupPost.find_by(id: params[:post]).nil?
              _comment = ::GroupPostComment.find_by(group_post_id: params[:post], id: params[:comment])
              if !_comment.nil?
                _attachment = ::GroupPostCommentAttachment.find_by(group_post_id: params[:post], group_post_comment_id: params[:comment], id: params[:id])
                if !_attachment.nil?
                  if _attachment.delete
                    response = { status: 200, message: 'Group post commnet attachment removed', content: nil }
                  else
                    response = { status: 500, message: 'Failed to remove forum post commnet attachment', content: nil }
                  end
                else
                  response = { status: 404, message: 'Group post commnet attachment not found', content: nil }
                end
              else
                response = { status: 404, message: 'Group post comment not found', content: nil }
              end
            else
              response = { status: 404, message: 'Group post not found', content: nil }
            end
          else
            response = { status: 404, message: 'Group not found', content: nil }
          end
        end

        return response
      end
    end
  end
end
