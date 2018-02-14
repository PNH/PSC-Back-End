module V1
  module Entities
    class Group < Grape::Entity
      expose :id, :title, :description, :updated_at, :privacy_level, :ismoderator, :ismember, :membercount, :created_at

      expose :ismoderator do |instance, options|
        _is_moderator = false
        current_user = options[:current_user]
        instance.group_moderators.each do |moderator|
          if moderator.user_id === current_user.id
            _is_moderator = true
            break
          else
            _is_moderator = false
          end
        end
        _is_moderator
      end

      expose :ismember do |instance, options|
        _is_member = false
        current_user = options[:current_user]
        instance.group_members.each do |member|
          if member.user_id === current_user.id
            _is_member = true
            break
          else
            _is_member = false
          end
        end
        _is_member
      end

      expose :membercount do |instance|
        instance.group_members.count
      end

      expose :group_moderators do |instance|
        moderators = []
        _moderators = instance.group_moderators
        _moderators.each do |moderator|
          _userObj = Group.userTemplate moderator.user
          moderators.push(
            _userObj
          )
        end
        moderators
      end
      expose :image do |instance, _options|
         if instance.image.nil?
           Rails.application.config.s3_source_path + 'default/GroupDefault.png'
         else
           instance.image.rich_file.url('groups_thumb')
         end
      end
      # expose :image do |instance, _options|
      #   if instance.image.nil?
      #     file = Rich::RichFile.find(Rails.application.secrets.goals_default_pic)
      #   else
      #     file = instance.image
      #   end
      #   file.rich_file.url('original')
      # end

      class GroupPost < Grape::Entity
        expose :id, :user_id, :content, :status, :group_id, :likes, :liked, :isowner, :updated_at, :commentcount, :created_at, :groupposting_type
        expose :user do |instance|
          owner = Group.userTemplate instance.user
        end

        expose :groupposting do |instance|
          post = nil
          if !instance.groupposting.nil?
            case instance.groupposting_type
            when 'Playlist'
              current_user = options[:current_user]
              post = {
                :id => instance.groupposting.id,
                :title => instance.groupposting.title,
                :resources => Entities::PlaylistResource.represent(instance.groupposting.playlist_resources, current_user: current_user)
              }
            end
          end
          post
        end

        expose :likes do |instance|
          instance.group_post_like.count
        end

        expose :liked do |instance|
          _is_liked = false
          current_user = options[:current_user]
          my_likes = ::GroupPostLike.where(group_id: instance.group_id, group_post_id: instance.id, user_id: current_user.id)
          if !my_likes.empty?
            _is_liked = true
          end
          _is_liked
        end

        expose :isowner do |instance|
          _is_owner = false
          current_user = options[:current_user]
          if instance.user_id === current_user.id
            _is_owner = true
          end
          _is_owner
        end

        expose :commentcount do |instance|
          instance.group_post_comment.count
        end

        expose :group_post_attachment do |instance|
          attachments = []
          instance.group_post_attachment.each do |attachment|
            _attachmentObj = Group.attachmentTemplate attachment
            attachments << _attachmentObj
          end
          attachments
        end
        expose :group_post_comment do |instance, options|
          current_user = options[:current_user]
          commnet_limit = options[:commnet_limit]
          comments = []
          instance.group_post_comment.order(created_at: :desc).limit(commnet_limit).each do |comment|
            _cobj = Group.commentTemplate(comment, current_user)
            comments.push(
              _cobj
            )
          end
          comments
        end

        # expose :image do |instance, _options|
        #   if instance.image.nil?
        #     file = Rich::RichFile.find(Rails.application.secrets.goals_default_pic)
        #   else
        #     file = instance.image
        #   end
        #   file.rich_file.url('original')
        # end
      end

      class GroupPostLike < Grape::Entity
        expose :id, :group_id, :group_post_id, :user_id, :status
      end

      class GroupPostComment < Grape::Entity
        expose :id, :group_post_id, :comment, :parent_id, :isowner, :updated_at, :created_at
        expose :user do |instance|
          Group.userTemplate instance.user
        end
        expose 'attachments' do |instance|
          V1::Entities::Group::GroupPostCommentAttachments.represent(instance.group_post_comment_attachments)
        end
      end

      class GroupPostAttachment < Grape::Entity
        expose :id, :group_post_id, :status
        expose :title do |instance|
          instance.resource.rich_file_file_name
        end
        expose :resource do |instance|
          instance.resource.nil? ? Rails.application.config.s3_source_path + 'default/GroupDefault.png' : instance.resource.rich_file.url('original')
        end
      end

      class GroupPostCommentAttachments < Grape::Entity
        expose :id
        expose :resource, as: :attachment do |instance|
          instance.resource.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.resource.rich_file.url('original')
        end
        expose 'type' do |instance|
          instance.resource.nil? ? nil : instance.resource.rich_file_content_type
        end
      end

      # private stuff

      def self.userTemplate (user)
        _userObj = nil
        if user
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

      def self.commentTemplate (comment, current_user)
        _owner = userTemplate(comment.user)
        _commnetObj = {
          'id' => comment.id,
          'group_post_id' => comment.group_post_id,
          'comment' => comment.comment,
          'parent_id' => comment.parent_id,
          'isowner' => current_user.id === comment.user_id ? true : false,
          'user' =>  _owner,
          'updated_at' => comment.updated_at,
          'created_at' => comment.created_at,
          'attachments' => V1::Entities::Group::GroupPostCommentAttachments.represent(comment.group_post_comment_attachments)
        }
        return _commnetObj
      end

      def self.attachmentTemplate (attachment)
        _attachmentObj = {
          'id' => attachment.id,
          'group_post_id' => attachment.group_post_id,
          'resourceUrl' => attachment.resource.nil? ? Rails.application.config.s3_source_path + 'default/GroupDefault.png' : attachment.resource.rich_file.url('original'),
          'status' => attachment.status
        }
        return _attachmentObj
      end

    end
  end
end
