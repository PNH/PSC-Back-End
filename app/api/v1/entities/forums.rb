module V1
  module Entities
    class Forums < Grape::Entity
      expose :id, :title, :description, :created_at, :updated_at
      expose :sub_forums  do |instance|
        sforums = []
        instance.sub_forums.where('status = true').each do |sub_forums|
          sforums.push(
            'id' => sub_forums.id,
            'title' => sub_forums.title,
            'description' => sub_forums.description,
            'created_at' => sub_forums.created_at,
            'updated_at' => sub_forums.updated_at,
            'post_count' => sub_forums.post_count,
            'user_count' => sub_forums.user_count,
            'topic_count' => sub_forums.topic_count
           )
        end
        sforums
      end

      expose :voices do |instance|
        instance.voices
      end

      expose :post_count do |instance|
        instance.post_count
      end

      expose :topic_count do |instance|
        instance.forum_count
      end

      expose :user_count do |instance|
        instance.user_count
      end

      # expose :user do |instance|
      # if instance.user.present?
      # owner = {
      #       'id' => instance.user.id,
      #       'firstName' => instance.user.first_name,
      #       'lastName' => instance.user.last_name,
      #       'profileImage' => instance.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.user.profile_picture.rich_file.url('original')
      #     }
      #   end
      # end
    end
  end
end
