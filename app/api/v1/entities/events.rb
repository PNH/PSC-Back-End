# frozen_string_literal: true
module V1
  module Entities
    class Events < Grape::Entity
      expose :id, :title, :description, :url
      expose :start_date, as: :startDate
      expose :end_date, as: :endDate
      expose :registration_opening_date, as: :openingDate
      expose :registration_closing_date, as: :closingDate
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt

      expose :status, as: :statusLabel
      # expose :status, as: :eventStatus do |instance|
      #   Event.statuses[instance.status]
      # end

      expose :organizer do |instance, options|
        current_user = options[:current_user]
        if !instance.event_organizer.nil?
          organizer = Entities::User.userPublicMiniTemplate(instance.event_organizer.user, current_user)
        end
      end

      expose :location do |instance|
        location = Entities::Event.locationTemplate(instance.event_location)
      end

      expose :categories do |instance|
        categories = []
        mappings = instance.event_category_mappings
        mappings.each do |mapping|
          categories << EventCategory.categoryTemplate(mapping.event_category)
        end
        categories
      end

      class EventCategory < Grape::Entity
        expose :id, :parent_id, :title, :description
        expose :children do |instance|
          children = []
          categories = instance.event_categories
          categories.each do |category|
            children << EventCategory.categoryTemplate(category)
          end
          children
        end

        def self.categoryTemplate(category)
          _catObj = nil
          if category
            _catObj = {
              'id' => category.id,
              'parent_id' => category.parent_id,
              'title' => category.title,
              'description' => category.description
            }
          end
          return _catObj
        end

      end

    end
  end
end
