# frozen_string_literal: true
module V1
  module Entities
    class Memberminute < Grape::Entity
      expose :id, :title, :description, :pdf_remote_url, :publish_date
      expose :memberminute_title do |instance, _options|
        instance.memberminute_section
      end
      expose :issue_title do |instance, _options|
        instance.savvytime_section
      end
      expose :pdf do |instance, _options|
        instance.pdf.rich_file.url unless instance.pdf.nil?
      end
      expose :thumbnail do |instance, _options|
        if instance.rich_file.nil?
          Rails.application.config.s3_source_path + 'default/MemberMinute.png'
        else
          instance.rich_file.rich_file.url('thumbxl')
        end
      end
      expose :banner do |instance, _options|
        if instance.rich_file.nil?
          Rails.application.config.s3_source_path + 'default/MemberMinute.png'
        else
          instance.rich_file.rich_file.url('banner')
        end
      end
      expose :memberminute_sections, as: :member_minute_sections do |instance, _options|

        attachments = []
        instance.member_minute_sections.where('status=true').member_minute.each do |attachment|
          attachments.push(
            'id' => attachment.id,
            'title' => attachment.title,
            'description' => attachment.description,
          )
        end
        attachments

        end
      
      expose :memberminute_sections, as: :issue do |instance, _options|
        attachments = []
        instance.member_minute_sections.where('status=true').savvy_time.each do |attachment|
          attachments.push(
            'id' => attachment.id,
            'title' => attachment.title,
            'description' => attachment.description
          )
        end
        attachments
      end

    end
  end
end