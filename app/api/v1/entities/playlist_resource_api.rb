# frozen_string_literal: true
module V1
  module Entities
    class PlaylistResourceAPI < Grape::Entity
      include CommonControllerConcern
      expose :id do |instance|
        instance.file.id
      end
      expose :type do |instance, _options|
        instance.file.simplified_type.upcase
      end
      expose :duration do |instance|
        instance.file.video_length
      end
      expose :thumbnail do |instance|
        instance.file.file_status == 1 && instance.file.simplified_type.eql?('video') ? instance.file.url('thumb') : Rails.application.config.s3_source_path + 'default/DefaultVideoLarge.png'
      end
      expose :path do |instance|
        instance.file.url('original')
      end
      expose :downloadpath do |instance|
        instance.file.low_quality_video_downloadpath.nil? ? instance.file.video_downloadpath : instance.file.low_quality_video_downloadpath.gsub("/asp/","/usp/")
      end
      expose :name do |instance|
        instance.title
      end
      expose :playlist do |instance, options|
        current_user = options[:current_user]
        ::Playlist.joins(:playlist_resources)
                  .where('playlists.user_id = ?', current_user.id)
                  .where('playlist_resources.file_id = ?', instance.file.id)
                  .pluck('playlists.id')
      end

      expose :subtitles do |instance|
        get_subtitles_for_api(instance.file.url('original'))
      end

      expose :updated_at do |instance|
        instance.updated_at
      end

      private

      def video_thumb
        Rails.application.config.s3_source_path + 'default/DefaultVideoLarge.png'
      end
    end
  end
end
