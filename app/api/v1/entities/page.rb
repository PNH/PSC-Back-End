# frozen_string_literal: true
module V1
  module Entities

    class Page < Grape::Entity
      expose :id, :title, :slug, :position
      expose :menu_title, as: :menu do |instance, _options|
        instance.menu_title
      end
      expose :display_type, as: :type do |instance, _options|
        instance.display_type
      end

      class PageDetailed < Grape::Entity
        expose :id, :title, :slug, :position, :content, :created_at
        expose :tags do |instance, _options|
          instance.tags.select(:id, :name)
        end
        expose :menu_title, as: :menu do |instance, _options|
          instance.menu_title
        end
        expose :display_type, as: :type do |instance, _options|
          instance.display_type
        end
        expose :attachments do |instance|
          _attachments = []
          instance.page_attachments.each do |attachment|
            _resource = attachment.resource
            # byebug
            _attachment = { id: _resource.id, name: attachment.title }
            file_content = (_resource.rich_file_content_type).split('/')
            next if (file_content[0] == 'video' || file_content[0] == 'audio') && (_resource.file_status != 1)
            _attachment.merge!(
              case file_content[0]
              when 'video'
                { type: 'video',
                  path: _resource.url('original'),
                  thumbnail: _resource.url('thumb').present? ? _resource.url('thumb') : Rails.application.config.s3_source_path + "default/DefaultVideoLarge.png",
                  duration: _resource.video_length.present? ? _resource.video_length : 0 }
              when 'image'
                { type: 'image',
                  path: _resource.url('original'),
                  thumbnail: _resource.url('thumb') }
              when 'audio'
                { type: 'audio',
                  path: _resource.url('original'),
                  thumbnail: Rails.application.config.s3_source_path + "default/DefaultVideoLarge.png",
                  duration: _resource.video_length.present? ? _resource.video_length : 0 }
              when 'application'
                case file_content[1]
                when 'pdf'
                  { type: 'pdf',
                    path: _resource.url('original') }
                when 'mp4'
                  { type: 'video',
                    path: _resource.url('original'),
                    thumbnail: _resource.url('thumb').present? ? _resource.url('thumb') : Rails.application.config.s3_source_path+"default/DefaultVideoLarge.png",
                    duration: _resource.video_length.present? ? _resource.video_length : 0 }
                else
                  { type: 'other',
                    path: _resource.url('original') }
                end
              else
                { type: 'other',
                  path: _resource.url('original') }
              end)
            _attachments << _attachment
          end
          _attachments
        end
      end

    end

  end
end
