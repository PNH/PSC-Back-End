module V1
  module Entities
    class SubForums < Grape::Entity
      expose :id, :title, :description, :created_at, :updated_at

      expose :forum_topics, :using => Entities::TopicDetail, as: :topics do |instance, _options|
        post_limit = _options[:post_limit].nil? ? 5 : _options[:post_limit]
        instance.forum_topics.where.not(is_sticky: true).order(created_at: :desc).limit(post_limit)
      end

      expose :topic_count do |instance|
        instance.forum_count
      end
      expose :post_count do |instance|
        instance.post_count
      end
      expose :user_count, as: :voices do |instance|
        instance.user_count
      end

      expose :stickies, :using => Entities::TopicDetail
      # , :using => V1::Entities::TopicDetail, as: :stickies do |instance, _options|
      #   instance.stickies
      # end

      expose :voices do |instance|
        instance.voices
      end

      expose :topic_count do |instance|
        instance.topic_count
      end

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
    end
  end
end
