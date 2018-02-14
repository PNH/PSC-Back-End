# frozen_string_literal: true
module V1
  module Entities
    class LearningLibrary
      class Video < Grape::Entity
        include CommonControllerConcern
        expose :file_id, as: :id
        expose :path do |instance, _options|
          instance.file.nil? ? '' : instance.file.url('original')
        end
        expose :thumbnail do |instance, _options|
          instance.file.file_status == 1 ? instance.file.url('thumb') : Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png"
        end
        expose :duration do |_instance|
          _instance.file.video_length
        end
        expose :title, as: :name
        expose :subtitles do |instance|
          get_subtitles(instance.file.url('original'))
        end
        expose :playlist do |instance, options|
          current_user = options[:current_user]
          ::Playlist.joins(:playlist_resources)
                    .where('playlists.user_id = ?', current_user.id)
                    .where('playlist_resources.file_id = ?', instance.file_id)
                    .pluck('playlists.id')
        end
      end

      class Audio < Grape::Entity
        expose :file_id, as: :id
        expose :title, as: :name
        expose :duration do |_instance|
          _instance.file.video_length
        end
        expose :path do |instance, _options|
          instance.file.nil? ? '' : (instance.file.file_status == -1 ? '' : instance.file.url('original'))
        end
        expose :thumbnail do |instance, _options|
          Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png"
        end
        expose :playlist do |instance, options|
          current_user = options[:current_user]
          ::Playlist.joins(:playlist_resources)
                    .where('playlists.user_id = ?', current_user.id)
                    .where('playlist_resources.file_id = ?', instance.file_id)
                    .pluck('playlists.id')
        end
      end

      class Document < Grape::Entity
        expose :file_id, as: :id
        expose :title, as: :name
        expose :path do |instance, _options|
          instance.file.nil? ? '' : instance.file.rich_file.url('original')
        end
        expose :thumbnail do |instance, _options|
          if instance.thumbnail.nil?
            # file = Rich::RichFile.find(Rails.application.secrets.video_thumb)
            # if !file.nil?
            #   file.rich_file.url('original')
            # end
            ''
          else
            instance.thumbnail.rich_file.url('thumbl')
          end
        end
        expose :file_type, as: :type
      end
    end
  end
end
