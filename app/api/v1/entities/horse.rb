# frozen_string_literal: true
module V1
  module Entities
    class Horse < Grape::Entity
      expose :id, :user_id, :name, :age, :breed, :color, :height, :weight, :bio
      expose :profilePic do |instance, _options|
         if instance.picture.nil?
           Rails.application.config.s3_source_path + 'default/HorseDefault.png'
         else
           instance.picture.rich_file.url('thumb')
         end
      end
      expose :height do |instance|
        instance.height.present? ? instance.height : nil
      end
      expose :weight do |instance|
        instance.weight.present? ? instance.weight : nil
      end
      expose :sex do |instance|
        ::Horse.sexes[instance.sex]
      end
      expose :horsenality do |instance|
        ::Horse.horsenalities[instance.horsenality]
      end
      expose :birthday do |instance|
        instance.birthday.try { |date| date.strftime(I18n.t('date.formats.default')) }
      end
      expose :level do |instance|
        instance.level.try(:id)
      end

      class HorseIssue < Grape::Entity
        expose :id do |instance|
          instance.issue.id
        end
        expose :title do |instance|
          instance.issue.title
        end

        expose :savvy do |instance|
          object = instance.issue.savvy
          savvy = {
            :id => object.id,
            :title => object.title,
            :image => object.logo.nil? ? Rich::RichFile.find(Rails.application.secrets.goals_default_pic).rich_file.url('original') : object.logo.rich_file.url('original')
          }
          savvy
        end
        expose :level do |instance|
          object = instance.issue.savvy.level
          level = {
            :id => object.id,
            :title => object.title,
            :color => object.color
          }
          level
        end
        expose :issueCategory do |instance|
          object = instance.issue.issue_category
          category = {
            :id => object.id,
            :title => object.title
          }
          category
        end
      end
    end
  end
end
