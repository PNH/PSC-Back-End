# frozen_string_literal: true
module V1
  module Entities
    class MemberminuteSection < Grape::Entity
      expose :id, :title, :description, :status
      expose :rich_file do |instance, _options|
        current_user = _options[:current_user]
        unless instance.rich_file.nil?
          vr = instance.rich_file
          case instance.file_type
          when 'video'
              {
                'id' => vr.id,
                'path' => vr.url('original'),
                'thumbnail' => vr.url('thumb').present? ? vr.url('thumb') : Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png",
                'duration' => vr.video_length.present? ? vr.video_length : 0,
                'playlist' => ::Playlist.joins(:playlist_resources).where('playlists.user_id = ?', current_user.id).where('playlist_resources.file_id = ?', vr.id).pluck('playlists.id')
              }
          when 'audio'
              {
                'id' => vr.id,
                'path' => vr.url('original'),
                'thumbnail' => Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png",
                'duration' => vr.video_length.present? ? vr.video_length : 0,
                'playlist' => ::Playlist.joins(:playlist_resources).where('playlists.user_id = ?', current_user.id).where('playlist_resources.file_id = ?', vr.id).pluck('playlists.id')
              }
          else
             {
                'path' => vr.url('original')
             }
          end
        end
      end
      expose :file_type, as: :kind do |instance|
        instance.file_type
      end
    end
  end
end
