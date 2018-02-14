module V1
  module Entities
    class BlogPost < Grape::Entity
      expose :id, :title, :status, :updated_at, :created_at, :user_id, :privacy, :slug, :summary

      expose :banner do |instance|
        instance.thumbnail.nil? ? Rails.application.config.s3_source_path + 'default/parelli_blogs_thumbnail.png' : instance.thumbnail.rich_file.url('blogs_thumb')
      end

      expose :author do |instance|
        unless instance.author.nil?
        owner = {
          'id' => instance.author.id,
          'firstName' => instance.author.first_name,
          'lastName' => instance.author.last_name,
          'profileImage' => instance.author.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.author.profile_picture.rich_file.url('thumb')
        }
        else
        owner = {
          'id' => 0,
          'firstName' => 'Deleted',
          'lastName' => 'User',
          'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
        }
        end
      end

      expose :comment_count do |instance|
        instance.blog_post_comments.count
      end

      expose :view_count do |instance|
        instance.views
      end

      expose :blog_categories do |instance|
        instance.blog_categories.select(:id, :name)
      end

      expose :tags do |instance|
        instance.tags.select(:id, :name)
      end

      expose :isowner do |instance, _options|
        current_user = _options[:current_user]
        if !current_user.nil?
          instance.author.present? && current_user.id == instance.author.id ? true : false
        else
          false
        end
      end

      expose :comment_count do |instance, options|
        instance.blog_post_comments.count
      end

    class Detail < Grape::Entity
      expose :id, :title, :content, :status, :updated_at, :created_at, :user_id, :privacy, :slug, :summary

      expose :banner do |instance|
        instance.thumbnail.nil? ? Rails.application.config.s3_source_path + 'default/parelli_blogs_banner.png' : instance.thumbnail.rich_file.url('banner')
      end

      expose :author do |instance|
        unless instance.author.nil?
        owner = {
          'id' => instance.author.id,
          'firstName' => instance.author.first_name,
          'lastName' => instance.author.last_name,
          'profileImage' => instance.author.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.author.profile_picture.rich_file.url('thumb')
        }
        else
        owner = {
          'id' => 0,
          'firstName' => 'Deleted',
          'lastName' => 'User',
          'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
        }
        end
      end

      expose :comment_count do |instance|
        instance.blog_post_comments.count
      end

      expose :view_count do |instance|
        instance.views
      end


      expose :blog_categories do |instance|
        instance.blog_categories.select(:id, :name)
      end

      expose :tags do |instance|
        instance.tags.select(:id, :name)
      end

      expose :blog_post_attachment do |instance|
        attachments = []
        instance.blog_post_attachments.each do |attachment|
          if attachment.resource.present?
            attachments.push(
              'id' => attachment.id,
              'blog_post_id' => attachment.blog_post_id,
              'title' => attachment.resource.rich_file_file_name,
              'resourceUrl' => attachment.resource.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : attachment.resource.rich_file.url('thumb'),
              'status' => attachment.status
            )
          end
        end
        attachments
      end

      expose :isowner do |instance, _options|
        current_user = _options[:current_user]
        if !current_user.nil?
          instance.author.present? && current_user.id == instance.author.id ? true : false
        else
          false
        end
      end

      expose :blog_post_comment do |instance, options|
        comments = []
        current_user = options[:current_user]
        commnet_limit = options[:commnet_limit].nil? ? 5 : options[:commnet_limit]
        instance.blog_post_comments.where(:parent_id => nil).order(created_at: :desc, id: :desc).page(1).per(commnet_limit).each do |comment|
          _comObj = {
            'id' => comment.id,
            'blog_post_id' => comment.blog_post_id,
            'comment' => comment.comment,
            'parent_id' => comment.parent_id,
            'created_at' => comment.created_at,
            'user_id' => instance.user_id,
            'isowner' => !current_user.nil? && current_user.id === comment.user_id ? true : false,
            'replies' => {
                'count': comment.blog_post_comments.count(),
                'comments': Entities::BlogPost::BlogPostComment.represent(comment.blog_post_comments.order(created_at: :desc, id: :desc).page(1).per(5), current_user: current_user)
            }
          }
          unless comment.user.nil?
            _is_member = false
            if ::User.roles[comment.user.role] == ::User.roles[:member]
              _is_member = true
            end

          _userObj = {
            'id' => comment.user.id,
            'firstName' => comment.user.first_name,
            'lastName' => comment.user.last_name,
            'profileImage' => comment.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : comment.user.profile_picture.rich_file.url('thumb'),
            'ismember' => _is_member
          }
          else
          _userObj = {
            'id' => 0,
            'firstName' => 'Deleted',
            'lastName' => 'User',
            'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png',
            'ismember' => false
          }
          end
          _comObj[:user] = _userObj
          comments.push(
            _comObj
          )
        end
        comments
      end
    end


      class BlogPostComment < Grape::Entity
        expose :id, :comment, :parent_id, :updated_at, :created_at, :user_id
        expose :owner, as: :user do |instance|
          unless instance.user.nil?
            _is_member = false
            if ::User.roles[instance.user.role] == ::User.roles[:member]
              _is_member = true
            end

          owner = {
            'id' => instance.user.id,
            'firstName' => instance.user.first_name,
            'lastName' => instance.user.last_name,
            'profileImage' => instance.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.user.profile_picture.rich_file.url('thumb'),
            'ismember' => _is_member
          }
        else
          owner = {
            'id' => 0,
            'firstName' => 'Deleted',
            'lastName' => 'User',
            'profileImage' => Rails.application.config.s3_source_path + 'default/UserDefault.png',
            'ismember' => false
          }
        end
        end
        expose :isowner do |instance, options|
          current_user = options[:current_user]
          if !current_user.nil?
            instance.user.present? && current_user.id === instance.user.id ? true : false
          else
            false
          end
        end
        expose 'replies' do |instance, options|
          current_user = options[:current_user]
          replies = {
              'count': instance.blog_post_comments.count(),
              'comments': Entities::BlogPost::BlogPostComment.represent(instance.blog_post_comments.order(created_at: :desc, id: :desc).page(1).per(5), current_user: current_user)
          }
        end
      end

    end
  end
end
