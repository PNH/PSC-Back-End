# frozen_string_literal: true
module V1
  module Entities
    class MemberminuteResource < Grape::Entity
      expose :id, :external_url, :title, :kind, :description
      expose :rich_file do |instance, _options|
        current_user = _options[:current_user]
        unless instance.rich_file.nil?
          vr = instance.rich_file
          case instance.kind
          when 'video'
              {
                'id' => vr.file_id,
                'path' => vr.url('original'),
                'thumbnail' => vr.url('thumb').present? ? vr.url('thumb') : Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png",
                'duration' => vr.video_length.present? ? vr.video_length : 0,
                'playlist' => ::Playlist.joins(:playlist_resources).where('playlists.user_id = ?', current_user.id).where('playlist_resources.file_id = ?', vr.file_id).pluck('playlists.id')
              }
          when 'audio'
              {
                'id' => vr.file_id,
                'path' => vr.url('original'),
                'thumbnail' => Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png",
                'duration' => vr.video_length.present? ? vr.video_length : 0,
                'playlist' => ::Playlist.joins(:playlist_resources).where('playlists.user_id = ?', current_user.id).where('playlist_resources.file_id = ?', vr.file_id).pluck('playlists.id')
              }
          else
             {
                'path' => vr.url('original')
             }
          end
        end
      end
    end
  end
end
