module V1
  module Entities
    class TopicDetail < Grape::Entity
      expose :id, :title, :short_description, :description, :privacy, :isowner, :membercount, :created_at, :updated_at

      expose :subForum do |instance|
        sub_frm = instance.sub_forum
        _sub_frm = nil
        if !sub_frm.nil?
          _sub_frm = {
            'id' => sub_frm.id,
            'title' => sub_frm.title
          }
          _sub_frm
        end
        _sub_frm
      end

      expose :post_count do |instance|
        instance.post_count
      end

      expose :user_count do |instance|
        instance.user_count
      end

      expose :forum_posts, :using => Entities::ForumPost, as: :posts do |instance, _options|
        post_limit = _options[:post_limit]
        instance.forum_posts.limit(post_limit)
      end

      expose :forum_moderators do |instance|
        moderators = []
        _moderators = instance.forum_moderators
        _moderators.each do |moderator|
          user = moderator.user
          unless user.nil?
          moderators.push(
          'id' => user.id,
          'firstName' => user.first_name,
          'lastName' => user.last_name,
          'profileImage' => user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : user.profile_picture.url('thumb')
          )
        else
          moderators.push(
          'id' => 0,
          'firstName' => 'Deleted',
          'lastName' => 'User',
          'profileImage' =>Rails.application.config.s3_source_path + 'default/UserDefault.png'
          )

        end
        end
        moderators
      end

      expose :image do |instance, _options|
         if instance.image.nil?
           Rails.application.config.s3_source_path + 'default/UserDefault.png'
         else
           instance.image.rich_file.url('thumbl')
         end
      end

      expose :user do |instance, _options|
        owner = Entities::TopicDetail.userTemplate(instance.forum_moderators.first.user) if instance.forum_moderators.count >0
        owner
      end

      expose :voices do |instance|
        instance.voices
      end

      expose :isowner do |instance, _options|
        isowner = false
        current_user = _options[:current_user]
        unless current_user.nil? || instance.forum_moderators.count == 0
          isowner = current_user.id === instance.forum_moderators.first.user_id ? true : false
        end
        isowner
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
            'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
          }
        end
        return _userObj
      end

    end
  end
end
