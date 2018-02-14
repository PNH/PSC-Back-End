# frozen_string_literal: true
module V1
  module Entities
    class Event < Grape::Entity
      expose :id, :title, :description, :url
      expose :start_date, as: :startDate
      expose :end_date, as: :endDate
      expose :registration_opening_date, as: :openingDate
      expose :registration_closing_date, as: :closingDate
      expose :created_at, as: :createdAt
      expose :updated_at, as: :updatedAt

      # expose :status, as: :statusLabel
      # expose :status, as: :eventStatus do |instance|
      #   Event.statuses[instance.status]
      # end
      expose :status do |instance|
        _statusObj = {
          'status' => ::Event.statuses[instance.status],
          'label' => instance.status
        }
      end

      expose :location do |instance|
        location = Entities::Event.locationTemplate(instance.event_location)
      end

      expose :organizer do |instance, options|
        current_user = options[:current_user]
        organizer = Entities::User.userPublicMiniTemplate(instance.event_organizer.user, current_user)
      end

      expose :instructors do |instance, options|
        current_user = options[:current_user]
        users = []
        instructors = instance.event_instructors
        unless instructors.empty?
          instructors.each do |instructor|
            _user = Entities::User.userPublicMiniTemplate(instructor.user, current_user)
            _user[:joinType] = {
              "key": EventInstructor.join_types[instructor.join_type],
              "value": instructor.join_type
            }
            users << _user
          end
        end
        users
      end

      expose :pricings do |instance|
        prices = []
        pricings = instance.event_pricings
        pricings.each do |pricing|
          prices << Entities::Event.pricingTemplate(pricing)
        end
        prices
      end

      expose :categories do |instance|
        categories = []
        mappings = instance.event_category_mappings
        mappings.each do |mapping|
          categories << Entities::Events::EventCategory.categoryTemplate(mapping.event_category)
        end
        categories
      end

      expose :isowner do |instance, options|
        _is_organizer = false
        current_user = options[:current_user]
        instance.event_organizer.user_id === current_user.id ? true : false
      end

      # expose :participantCount do |instance|
      #   instance.event_participants.count
      # end

      expose :participationStatus do |instance, options|
        current_user = options[:current_user]
        _participation = EventParticipant.participation(instance.id, current_user.id)
        _status = {
          'status' => _participation.nil? ? EventParticipant.statuses[:unknown] : EventParticipant.statuses[_participation.status],
          'label' => _participation.nil? ? EventParticipant.statuses[:unknown] : _participation.status,
          'participants' => instance.event_participants.count
        }
      end

      # expose :participanton do |instance|
      #   current_user = options[:current_user]
      #   _status = EventParticipant.statuses[:unknown]
      #   _participation = EventParticipant.participation(instance.id, current_user.id)
      #   if !_participation.nil?
      #     _status = EventParticipant.statuses[_participation.status]
      #   end
      #   _status
      # end
      #
      # expose :participantonLabel do |instance|
      #   current_user = options[:current_user]
      #   _status = EventParticipant.statuses[:unknown]
      #   _participation = EventParticipant.participation(instance.id, current_user.id)
      #   if !_participation.nil?
      #     _status = _participation.status
      #   end
      #   _status
      # end

      # private stuff

      def self.locationTemplate (location)
        _locObj = nil
        if location
          _locObj = {
            'id' => location.id,
            'address' => location.full_address,
            'street' => location.street,
            'state' => location.state,
            'city' => location.city,
            'country' => location.country,
            'zipcode' => location.zipcode,
            'latitude' => location.latitude,
            'longitude' => location.longitude
          }
        end
        return _locObj
      end

      def self.pricingTemplate (pricing)
        _pricingObj = {
          'id' => pricing.id,
          'title' => pricing.title,
          'description' => pricing.description,
          'price' => pricing.price
        }
      end

    end
  end
end
