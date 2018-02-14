# frozen_string_literal: true
module V1
  module Entities
    class Issue < Grape::Entity
      expose :id, :title
      expose :savvy do |instance, _options|
        {
          id: instance.savvy.id,
          title: instance.savvy.title,
          logo: instance.savvy.logo.nil? ? '' : instance.savvy.logo.rich_file.url('original')

        }
      end
      expose :level do |instance, _options|
        {
          id: instance.savvy.level.id,
          title: instance.savvy.level.title,
          slug: instance.savvy.level.slug
        }
      end
    end
  end
end
