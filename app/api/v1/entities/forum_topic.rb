module V1
  module Entities
    class ForumTopic < Grape::Entity

      expose :id, :title, :short_description, :description, :privacy, :isowner, :membercount, :created_at, :updated_at

      expose :post_count do |instance|
        instance.post_count
      end

      expose :user_count do |instance|
        instance.user_count
      end

      expose :forum_moderators do |instance|
        moderators = []
        _moderators = instance.forum_moderators
        _moderators.each do |moderator|
          next if moderator.nil?
          user = moderator.user
          moderators.push(
          'id' => user.id,
          'firstName' => user.first_name,
          'lastName' => user.last_name,
          'profileImage' => user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : user.profile_picture.url('thumb')
          )
        end
        moderators
      end

      expose :voices do |instance|
        instance.voices
      end

      expose :image do |instance, _options|
         if instance.image.nil?
           Rails.application.config.s3_source_path + 'default/UserDefault.png'
         else
           instance.image.rich_file.url('original')
         end
      end

      expose :user do |instance, _options|
        if instance.forum_moderators.count > 0
          owner = ForumTopic.userTemplate(instance.forum_moderators.first.user)
          if owner.nil?
          owner = {
              'id' => 0,
              'firstName' => 'Deleted',
              'lastName' => 'User',
              'profileImage' => Rails.application.config.s3_source_path + 'default/UserDefault.png'
            }
          end
        else
            owner = {
              'id' => 0,
              'firstName' => 'Deleted',
              'lastName' => 'User',
              'profileImage' => Rails.application.config.s3_source_path + 'default/UserDefault.png'
            }
        end
        owner
      end

      class ForumPostLike < Grape::Entity
        expose :id, :forum_id, :forum_post_id, :user_id, :status
      end

      class ForumPostComment < Grape::Entity
        expose :id, :forum_post_id, :comment, :parent_id, :updated_at, :created_at
        expose :user do |instance|
          unless instance.user.nil?
          owner = {
            'id' => instance.user.id,
            'firstName' => instance.user.first_name,
            'lastName' => instance.user.last_name,
            'profileImage' => instance.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.user.profile_picture.rich_file.url('thumb')
          }
        else
          owner = {
            'id' => 0,
            'firstName' => 'Deleted',
            'lastName' => 'User',
            'profileImage' => Rails.application.config.s3_source_path + 'default/UserDefault.png'
          }
        end
        end
        expose :isowner do |instance, options|
          current_user = options[:current_user]
          instance.user.present? && instance.isowner = current_user.id === instance.user.id ? true : false
        end
        expose 'attachments' do |instance, options|
          V1::Entities::ForumPost::ForumPostCommentAttachments.represent(instance.forum_post_comment_attachments)
        end
      end

      class ForumPostAttachment < Grape::Entity
        expose :id, :forum_post_id, :status
        expose :resource do |instance|
          instance.resource.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.resource.rich_file.url('original')
        end
      end

      # private stuff

      def self.userTemplate (user)
        unless user.nil?
          _userObj = {
            'id' => user.id,
            'firstName' => user.first_name,
            'lastName' => user.last_name,
            'profileImage' => user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : user.profile_picture.url('thumb')
          }
          else
            _userObj = {
              'id' => 0,
              'firstName' => 'Deleted',
              'lastName' => 'User',
              'profileImage' => Rails.application.config.s3_source_path + 'default/UserDefault.png'
            }
          end
        return _userObj
      end

    end
end
end
