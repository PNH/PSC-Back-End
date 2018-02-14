# frozen_string_literal: true
module V1
  module Entities
    class Goals < Grape::Entity
      expose :id, :title
      expose :image do |instance, _options|
        if instance.image.nil?
          file = Rich::RichFile.find(Rails.application.secrets.goals_default_pic)
        else
          file = instance.image
        end
        file.rich_file.url('original')
      end
    end
  end
end
