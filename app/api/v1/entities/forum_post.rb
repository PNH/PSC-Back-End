module V1
  module Entities
    class ForumPost < Grape::Entity
      expose :id, :user_id, :content, :status, :forum_id, :likes, :liked, :isowner, :updated_at, :commentcount, :created_at
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
          'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
        }
        end
      end
      expose :forum_post_attachment do |instance|
        attachments = []
        instance.forum_post_attachment.each do |attachment|
          attachments.push(
            'id' => attachment.id,
            'title' => attachment.resource.rich_file_file_name,
            'forum_post_id' => attachment.forum_post_id,
            'resourceUrl' => attachment.resource.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : attachment.resource.rich_file.url('original'),
            'status' => attachment.status
          )
        end
        attachments
      end

      expose :isowner do |instance, _options|
        current_user = _options[:current_user]
        instance.isowner = instance.user.present? && current_user.id == instance.user.id ? true : false
      end

      expose :commentcount do |instance|
        instance.commentcount = instance.forum_post_comment.count
      end

      expose :forum_post_comment do |instance, options|
        comments = []
        current_user = options[:current_user]
        commnet_limit = options[:commnet_limit].nil? ? 5 : options[:commnet_limit]
        instance.forum_post_comment.order(:created_at).limit(commnet_limit).each do |comment|
          _comObj = {
            'id' => comment.id,
            'forum_post_id' => comment.forum_post_id,
            'comment' => comment.comment,
            'parent_id' => comment.parent_id,
            'isowner' => current_user.id === comment.user_id ? true : false,
            'user' => nil,
            'created_at' => comment.created_at
          }
          unless comment.user.nil?
          _userObj = {
            'id' => comment.user.id,
            'firstName' => comment.user.first_name,
            'lastName' => comment.user.last_name,
            'profileImage' => comment.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : comment.user.profile_picture.rich_file.url('thumb')
          }
          else
          _userObj = {
            'id' => 0,
            'firstName' => 'Deleted',
            'lastName' => 'User',
            'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
          }
          end
          _comObj[:user] = _userObj
          _comObj[:attachments] = V1::Entities::ForumPost::ForumPostCommentAttachments.represent(comment.forum_post_comment_attachments)
          comments.push(
            _comObj
          )
        end
        comments
      end

      class ForumPostCommentAttachments < Grape::Entity
        expose :id
        expose :resource, as: :attachment do |instance|
          instance.resource.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.resource.rich_file.url('original')
        end
        expose 'type' do |instance|
          instance.resource.nil? ? nil : instance.resource.rich_file_content_type
        end
      end

    end

  end
end
