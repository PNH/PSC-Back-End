module V1
  module Entities
    class SavvyEssential < Grape::Entity
      expose :id, :title, :description
      expose :publication_date, as: :publicationDateObject

      expose :publicationDate do |instance|
        instance.publication_date.strftime("%B %Y")
      end

      expose :resource do |instance|
        { path: instance.resource.url('original'),
          thumbnail: instance.resource.url('thumb'),
          banner: instance.resource.url('banner'),
          thumbnail_extra: instance.resource.url('blogs_thumb') }
      end

      expose :additionals do |instance|
        { printable_action_plan: (instance.action_plan.nil? ? nil : instance.action_plan.url('original')),
          additional_content: instance.additional_content }
      end

      expose :publicationSections do |instance|
        sections = []
        instance.savvy_essential_publication_sections.where(status: true).each do |section|
          next unless section.publication_section.status
          section_info =  {
            id: section.id,
            title: section.publication_section.title,
            description: section.description,
            attachments: []
          }
          section.publication_attachments.each do |attachment|
            _resource = attachment.resource
            # byebug
            _attachment = { id: _resource.id, name: attachment.name }
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
            section_info[:attachments] << _attachment
          end
          sections << section_info
        end
        sections
      end
    end
  end
end
