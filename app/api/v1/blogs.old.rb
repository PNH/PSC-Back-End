module V1
  class Blogs < Grape::API
    prefix 'api'
    resource :blogs do
    end

    namespace 'blog/posts' do
      params do

        requires :page, type: Integer
        requires :limit, type: Integer
        optional :commentLimit, type: Integer
        optional :orderby, type: Integer
        optional :search, type: String
        optional :year, type: Integer
        optional :month, type: Integer
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

        blogs = Blog.where(:status => 1)
        if blogs.empty?
          return {
              status: 404,
              message: 'Blog not found',
              content: nil
            }
        end
        blog = blogs.first
        commentLimit = params[:search].nil? ? 5 : params[:commentLimit]
        orderby = (params[:orderby].present? && params[:orderby] == 1) ? 'created_at desc' : 'views desc'

        unless params[:year].nil? || params[:month].nil?
          posts = ::BlogPost.where('extract(year  from created_at) = ? AND extract(month  from created_at) = ? ', params[:year], params[:month]).where(:status=>::BlogPost.statuses[:enable]).order(orderby, id: :asc).page(params[:page]).per(params[:limit])
        else
          if params[:search].present?
            if current_user.member? || current_user.admin? || current_user.super_admin?
              posts = ::BlogPost.where(blog_id: blog.id).where("lower(title) LIKE ? OR lower(content) LIKE ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").where(:status=>::BlogPost.statuses[:enable]).order(orderby, id: :asc).page(params[:page]).per(params[:limit])
            else
              posts = ::BlogPost.where(blog_id: blog.id).where("lower(title) LIKE ? OR lower(content) LIKE ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").where('privacy =? or privacy is null', Privacysetting.statuses[:privacy_public]).where(:status=>::BlogPost.statuses[:enable]).order(orderby, id: :asc).page(params[:page]).per(params[:limit])
            end
          else
            if current_user.member? || current_user.admin? || current_user.super_admin?
              posts = ::BlogPost.where(blog_id: blog.id).where(:status=>::BlogPost.statuses[:enable]).order(orderby).page(params[:page]).per(params[:limit])
            else
              posts = ::BlogPost.where(blog_id: blog.id).where('privacy =? or privacy is null', Privacysetting.statuses[:privacy_public]).where(:status=>::BlogPost.statuses[:enable]).order(orderby).page(params[:page]).per(params[:limit])
            end
          end
        end

        if !posts.nil? && posts.count > 0
          return {
            status: 200,
            message: 'Blog posts found',
            content: Entities::BlogPost.represent(posts, current_user: current_user, commnet_limit: commentLimit)
          }
        else
          return {
            status: 404,
            message: 'Blog posts not found',
            content: nil
          }
        end
      end

      params do
        requires :title, type: String
        requires :content, type: String
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

        blogs = Blog.where(:status => 1)
        if blogs.empty?
          return {
              status: 404,
              message: 'Blog not found',
              content: nil
            }
        end
        blog = blogs.first

          post_status = BlogPost.statuses[:disable]
          privacy = params[:privacy].nil? ? Privacysetting.statuses[:privacy_public] : params[:privacy]

          if !blog.blog_moderators.where(:user_id=>current_user.id).empty?
            post_status = ::BlogPost.statuses[:enable]
            post = ::BlogPost.new(status: post_status, user_id: current_user.id, privacy: privacy, title: params[:title], content: params[:content], blog_id: blog.id )
          else
            post_status = ::BlogPost.statuses[:pending]
            post = ::BlogPost.new(status: post_status, user_id: current_user.id, privacy: privacy, title: params[:title], content: params[:content], blog_id: blog.id )
          end


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
                  post_attachment = BlogPostAttachment.new(blog_post_id: post.id, resource: _banner_img, status: 1)
                  post_attachment.save
                else
                  error_msg = "One or more invalid attachment/s found."
                end
              end
            end

            success_msg = ""
            case post_status
            when BlogPost.statuses[:enable]
              success_msg = "Post added"
            when BlogPost.statuses[:pending]
              success_msg = "Post added to pending list"
            else
              success_msg = "Action unknown"
            end

            return {
              status: 200,
              message: error_msg.nil? ? success_msg : error_msg,
              content: Entities::BlogPost.represent(post, current_user: current_user, commnet_limit: 5)
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

    namespace 'blog/archive' do
      get do
        authenticate_user
          unless  authenticated?
            return {
              status: 401,
              message: 'Unauthorized',
              content: ''
            }
          end
          years = []

          blogs = Blog.where(:status => 1)
          if blogs.empty?
            return {
                status: 404,
                message: 'Blog not found',
                content: nil
              }
          end
          blog = blogs.first


          if current_user.member? || current_user.admin? || current_user.super_admin?
            resources = ::BlogPost.where(blog_id: blog.id).order('created_at desc')
          else
            resources = ::BlogPost.where(blog_id: blog.id).where('privacy =? or privacy is null', Privacysetting.statuses[:privacy_public]).order('created_at desc')
          end

        resource_years = resources.group_by { |t| t.created_at.beginning_of_year }
        resource_years.sort.reverse.each do |_year, _yresources|
            months = []
            _yresources.group_by { |t| t.created_at.beginning_of_month }.each do |_month, _mresources|
              months << {:name =>  _month.strftime("%B"), :count => _mresources.count}
            end
          years << {:name => _year.strftime("%Y") , :months => months}
        end
        {
          status: 200,
          message: '',
          content: years
        }
        end
      end

    namespace 'blog/posts/:post_id' do

      params do
        requires :post_id, type: Integer
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

        blogs = Blog.where(:status => 1)
        if blogs.empty?
          return {
              status: 404,
              message: 'Blog not found',
              content: nil
            }
        end
        blog = blogs.first
        commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]

        if current_user.member? || current_user.admin? || current_user.super_admin?
          posts = ::BlogPost.where(id: params[:post_id])
        else
          posts = ::BlogPost.where(id: params[:post_id]).where('privacy =? or privacy is null', Privacysetting.statuses[:privacy_public])
        end

          if !posts.empty? && posts.count > 0
            post = posts.first
            post.views = post.views.to_i + 1
            post.save!

            return {
              status: 200,
              message: 'Blog posts found',
              content: Entities::BlogPost::Detail.represent(posts, current_user: current_user, commnet_limit: commentLimit)
            }
          else
            return {
              status: 404,
              message: 'Blog posts not found',
              content: nil
            }
          end
      end

      params do
        requires :post_id, type: Integer
        requires :privacy, type: Integer
        requires :title, type: String
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

        blogs = Blog.where(:status => 1)
        if blogs.empty?
          return {
              status: 404,
              message: 'Blog not found',
              content: nil
            }
        end
        blog = blogs.first

          post = ::BlogPost.find_by_id params[:post_id]
          if !post.nil? && (post.author.id = user_id || current_user.admin?  || current_user.super_admin? )

            if post.update(title: params[:title], content: params[:content], privacy: params[:privacy])
              return {
                status: 200,
                message: 'Post updated',
                content: Entities::BlogPost.represent(post, current_user: current_user, commnet_limit: 5)
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

          post = ::BlogPost.find_by_id params[:post_id]
          if post.present?
            unless post.author.id == user_id || current_user.admin? || current_user.super_admin?
              return {
                status: 301,
                message: 'Action not permitted',
                content: nil
              }
            end

            if post.destroy!

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

    namespace 'blog/posts/:post_id/attachment/:id' do
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
        post = ::BlogPost.find_by_id params[:post_id]

        if post.present?

          _banner_img = Rich::RichFile.new
          _file_attrs = params[:attachment]
          _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
          # _banner_img.id = Rich::RichFile.last.id + 1
          _banner_img.rich_file = _file_params
          _banner_img.rich_file_file_name = _file_attrs[:filename]

          post_attachment = BlogPostAttachment.new(blog_post_id: post.id, resource: _banner_img, status: 1)
          if post_attachment.save

            response = {
              status: 200,
              message: 'Attachment added',
              content: Entities::BlogPost::Detail.represent(post, current_user: current_user, commnet_limit: 5)
            }
          else

            # post_attachment.resource.id = Rich::RichFile.last.id + 1
            if post_attachment.save
                response = {
                status: 200,
                message: 'Attachment added',
                content: Entities::BlogPost::Detail.represent(post, current_user: current_user, commnet_limit: 5)
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

        post = ::BlogPost.find_by_id params[:post_id]

        if posts.present?

          attachments = BlogPostAttachment.where id: params[:id], blog_post_id: params[:post_id]
          if !attachments.empty?

            attachment = attachments.first

            if attachment.delete

              response = {
                status: 200,
                message: 'Attachment removed from post',
                content: Entities::BlogPost::Detail.represent(post, current_user: current_user, commnet_limit: 5)
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

    namespace 'blog/posts/:post_id/comments' do
      params do
        requires :post_id, type: Integer
        # requires :user_id, type: Integer
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :parentId, type: Integer
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

          comments = nil

          comments = ::BlogPostComment.where(blog_post_id: params[:post_id], parent_id: params[:parentId]).order(created_at: :desc, id: :asc).page(params[:page]).per(params[:limit])

          if !comments.empty?
            response = {
              status: 200,
              message: 'Comments found',
              content: Entities::BlogPost::BlogPostComment.represent(comments,current_user: current_user)
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
        # for guests
        optional :name, type: String
        optional :email, type: String
        optional :recaptcha, type: String
      end
      post do
        response = { status: 404, message: 'Blog post not found', content: nil }
        post = ::BlogPost.find_by_id(params[:post_id])
        if !post.nil?
          user = nil
          comment = nil
          authenticate_user
          if authenticated?
            user = current_user
            comment = ::BlogPostComment.new(user_id: user.id, blog_post_id: params[:post_id], comment: params[:comment], parent_id: params[:parentId])
          else
            # for guests, create a new user
            if params[:name].nil? || params[:email].nil? || params[:recaptcha].nil?
              response = { status: 400, message: 'Guest user info missing', content: nil }
            else
              is_success = is_recaptcha_pass(params[:recaptcha])
              if is_success
                user = User.find_by email: params[:email], role: [::User.roles[:guest], ::User.roles[:deleted]]
                if user.nil?
                  names = params[:name].split(' ')
                  f_name = names[0]
                  l_name = names[1].nil? ? "" : names[1]
                  user = User.new(email: params[:email], first_name: f_name, last_name: l_name, password: Devise.friendly_token.first(8), role: ::User.roles[:guest])
                  if user.save
                    comment = ::BlogPostComment.new(user_id: user.id, blog_post_id: params[:post_id], comment: params[:comment], parent_id: params[:parentId])
                  else
                    ext_user = User.find_by email: params[:email], role: ::User.roles[:member]
                    if !ext_user.nil?
                      response = { status: 400, message: 'This email belongs to a registered user. Please Sign In to add the comment.', content: nil }
                    else
                      response = { status: 500, message: 'Failed to add the guest user to system', content: nil }
                    end
                  end
                else
                  comment = ::BlogPostComment.new(user_id: user.id, blog_post_id: params[:post_id], comment: params[:comment], parent_id: params[:parentId])
                end
              else
                response = { status: 400, message: 'Captcha Failed, please try again', content: nil }
              end
            end
          end

          if !comment.nil?
            if comment.save
              response = { status: 201, message: 'Comment added', content: Entities::BlogPost::BlogPostComment.represent(comment, current_user: user) }
            else
              response = { status: 500, message: 'Failed to add comment', content: nil }
            end
          end
        end

        return response
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

        post = ::BlogPost.find_by_id(params[:post_id])
        if post.present?
          comment = BlogPostComment.new(user_id: user_id, blog_post_id: params[:post_id], comment: params[:comment], parent_id: params[:parentId])
          if comment.save

            response = {
              status: 200,
              message: 'Post comment added',
              content: Entities::BlogPost::BlogPostComment.represent(comment,current_user: current_user)
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

    namespace 'blog/posts/:post_id/comments/:id' do

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
          comments = BlogPostComment.where id: params[:id]
          if !comments.empty? && (comments.first.user_id == user_id || current_user.admin? || current_user.super_admin?)
            comment = comments.first
            success = comment.update(comment: params[:comment])
            if success

              response = {
                status: 200,
                message: 'Comment updated',
                content: Entities::BlogPost::BlogPostComment.represent(comment,current_user: current_user)
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
          comments = BlogPostComment.where id: params[:id]
          unless comments.empty?
          comment = comments.first
            unless comment.blog_post.user_id == user_id || comment.user_id == user_id || current_user.admin? || current_user.super_admin?
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

    helpers do
    def is_recaptcha_pass(recaptcha)
        require 'unirest'

        response = Unirest.post "https://www.google.com/recaptcha/api/siteverify", parameters:{ :secret => Rails.application.secrets.google_recaptcha_secret, :response => recaptcha }

        is_success = true
        if response.code == 200
          if response.body['success'] == true
            is_success = true
          end
        end

        return is_success
      end
    end

  end
end
