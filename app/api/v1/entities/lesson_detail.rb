# frozen_string_literal: true
module V1
  module Entities
    class LessonDetail < Grape::Entity
      include CommonControllerConcern
      expose :id, :title, :description, :objective, :slug, :kind
      expose :videos do |instance, _options|
        current_user = _options[:current_user]
        user_id = current_user.nil? ? nil : current_user.id
        instance.video_resources.joins(:rich_file).merge(Rich::RichFile.where("file_status = ?", 1)).map do |vr|
            {
              'id' => vr.rich_file_id,
              'name' => vr.title,
              'path' => vr.rich_file.url('original'),
              'thumbnail' => vr.rich_file.file_status == 1 ? vr.rich_file.url('thumb') : video_thumb,
              'duration' => vr.rich_file.video_length,
              'subtitles' => get_subtitles(vr.rich_file.url('original')),
              'position' => vr.position,
              'playlist' => ::Playlist.joins(:playlist_resources).where('playlists.user_id = ?', user_id).where('playlist_resources.file_id = ?', vr.rich_file_id).pluck('playlists.id')
            }
        end
      end
      expose :audios do |instance, _options|
        current_user = _options[:current_user]
        user_id = current_user.nil? ? nil : current_user.id
        instance.audio_resources.joins(:rich_file).merge(Rich::RichFile.where("file_status = ?", 1)).map do |ar|
            {
              'id' => ar.rich_file_id,
              'name' => ar.title,
              'path' => ar.rich_file.url('original'),
              'thumbnail' => video_thumb,
              'duration' => ar.rich_file.video_length,
              'position' => ar.position,
              'playlist' => ::Playlist.joins(:playlist_resources).where('playlists.user_id = ?', user_id).where('playlist_resources.file_id = ?', ar.rich_file_id).pluck('playlists.id')
            }
          end
      end
      expose :documents do |instance, _options|
        instance.document_resources.map do |dr|
          {
            'id' => dr.rich_file_id,
            'name' => dr.title,
            'path' => dr.rich_file.rich_file.url('original'),
            'position' => dr.position
          }
        end
      end
      expose :chat_bubble do |instance, _options|
        chat_bubble = instance.chat_bubbles.order('RANDOM()').first
        if chat_bubble.nil?
          {}
        else
          {
            'id' => chat_bubble.id,
            'author' => chat_bubble.user.name,
            'message' => chat_bubble.message,
            'profile_picture' => profile_picture(chat_bubble.user),
            'user_country' => user_country(chat_bubble.user)
          }
        end
      end
      expose :lesson_tools do |instance, _options|
        instance.lesson_tool.map do |lt|
          {
            'id' => lt.id,
            'title' => lt.title
          }
        end
      end
      expose :lessonCompleted do |lesson, options|
        unless options[:request].blank?
          horse_id = options[:request]['horseId']
          horse = ::Horse.find(horse_id)
          horse.lesson_completed?(lesson)
        end
      end
      expose :nextLesson do |lesson, _options|
        next_lesson = lesson.lower_items
                            .where(kind: ::Lesson.kinds.values_at(:default))
                            .where(deleted_at: nil)
                            .first
        next_lesson.nil? ? nil : next_lesson.id
      end

      private

      def profile_picture(user)
        if user.profile_picture.nil?
          Rails.application.config.s3_source_path+"default/UserDefault.png"
        else
          user.profile_picture.rich_file.url('thumb')
        end
      end

      def user_country(user)
        country = user.home_address.try(:country)
        country = ISO3166::Country.new(country) unless country.blank?
        country.name unless country.blank?
      end

      def video_thumb
        Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png"
      end
    end
  end
end
