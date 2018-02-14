# frozen_string_literal: true
module V1
  class Events < Grape::API
    prefix 'api'

    # _europian_union = ["be", "bg", "cz", "dk", "de", "ee", "ie", "el", "es", "fr", "hr", "it", "cy", "lv", "lt", "lu", "hu", "mt", "nl", "at", "pl", "pt", "ro", "si", "sk", "fi", "se"]
    _europe = ["al", "ad", "am", "at", "be", "ba", "bg", "ch", "cy", "cz", "de", "dk", "ee", "es", "fo", "fi", "fr", "ge", "gi", "gr", "hu", "hr", "ie", "is", "it", "lt", "lu", "lv", "mc", "mk", "mt", "no", "nl", "po", "pt", "ro", "ru", "se", "si", "sk", "sm", "tr", "ua", "va"]

    namespace 'events/meta' do
      get do
        response = { status: 200, message: 'EventInstructor types', content: EventInstructor.join_types }
        return response
      end
    end

    # Events
    namespace 'events' do
      params do
        requires :country, type: String
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :zipcode, type: String
        optional :radius, type: Integer
        optional :startDate, type: DateTime
        optional :endDate, type: DateTime
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          events = []
          locations = []
          zipcode = params[:zipcode]
          radius = params[:radius].nil? ? 10 : params[:radius]
          country = params[:country].downcase
          page = params[:page]
          limit = params[:limit]

          startDate = nil
          endDate = nil
          if !params[:startDate].nil?
            startDate = params[:startDate].beginning_of_day
            endDate = params[:endDate].nil? ? startDate : params[:endDate]
            # endDate = endDate - 2.day # additional 48 hours
          else
            startDate = DateTime.now.beginning_of_day
            # endDate = startDate - 2.day
          end

          # region new way
          case country
          when "all"
            country = nil
          when "us", "gb", "au"
            country = country
          when "eu"
            country = _europe
          else
            country = country
          end

          # third take on this filter bullshit

          if params[:startDate].nil? && country.nil?
            # startDate = DateTime.now.beginning_of_day
            endDate = startDate - 2.day
            events = Event.all.where("start_date >= ? OR ? <= end_date", startDate, endDate).order('events.start_date asc, events.id').page(page).per(limit)
          elsif country.nil?
            if zipcode.nil?
              events = Event.all.where("? >= events.start_date AND ? <= events.end_date", startDate, endDate).order('events.start_date asc, events.id').page(page).per(limit)
            else
              locations = EventLocation.near(zipcode, radius).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, endDate).order('events.start_date asc, events.id').page(page).per(limit)
            end
          elsif params[:startDate].nil?
            endDate = startDate - 2.day
            if zipcode.nil?
              locations = EventLocation.where(country: country).joins(:event).where("events.start_date >= ? OR ? <= events.end_date", startDate, endDate).order('events.start_date asc, events.id').page(page).per(limit)
            else
              locations = EventLocation.where(country: country).joins(:event).where("events.start_date >= ? OR ? <= events.end_date", startDate, endDate).near(zipcode, radius).order('events.start_date asc, events.id').page(page).per(limit)
            end
          else
            if zipcode.nil?
              locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, endDate).order('events.start_date asc, events.id').page(page).per(limit)
            else
              locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, endDate).near(zipcode, radius).order('events.start_date asc, events.id').page(page).per(limit)
            end
          end

          # end third take

          # if startDate.nil? && country.nil? # this condition will never pass, look above
          #   events = Event.all.order('events.start_date asc').page(page).per(limit)
          # elsif country.nil?
          #   if zipcode.nil?
          #     events = Event.all.where("? >= start_date AND ? <= end_date", startDate, endDate).order('events.start_date asc').page(page).per(limit)
          #   else
          #     locations = EventLocation.near(zipcode, radius).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, endDate).order('events.start_date asc').page(page).per(limit)
          #   end
          # elsif startDate.nil? # this condition will never pass, look above
          #   if zipcode.nil?
          #     locations = EventLocation.where(country: country).joins(:event).order('events.start_date asc').page(page).per(limit)
          #   else
          #     locations = EventLocation.where(country: country).joins(:event).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #   end
          # else
          #   if zipcode.nil?
          #     locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, endDate).order('events.start_date asc').page(page).per(limit)
          #   else
          #     locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, endDate).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #   end
          # end

          # if params[:startDate].nil?
          #   events = Event.all.order('events.start_date asc').page(page).per(limit)
          # else
          #
          #   case country
          #   when "all"
          #     if zipcode.nil?
          #       # events:{:start_date => startDate..endDate} the right way that should happen, but well..
          #       events = Event.all.where("? >= start_date AND ? <= end_date", startDate, startDate).order('events.start_date asc').page(page).per(limit)
          #     else
          #       locations = EventLocation.near(zipcode, radius).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, startDate).order('events.start_date asc').page(page).per(limit)
          #     end
          #
          #   when "us", "uk", "au"
          #     if zipcode.nil?
          #       # locations = EventLocation.where(country: country).joins(:event).where(events:{:start_date => startDate..endDate}).order('events.start_date asc').page(page).per(limit)
          #       locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, startDate).order('events.start_date asc').page(page).per(limit)
          #     else
          #       # locations = EventLocation.where(country: country).joins(:event).where(events:{:start_date => startDate..endDate}).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #       locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, startDate).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #     end
          #
          #   when "eu"
          #     if zipcode.nil?
          #       # locations = EventLocation.where(country: _europian_union).joins(:event).where(events:{:start_date => startDate..endDate}).order('events.start_date asc').page(page).per(limit)
          #       locations = EventLocation.where(country: _europian_union).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, startDate).order('events.start_date asc').page(page).per(limit)
          #     else
          #       # locations = EventLocation.where(country: _europian_union).joins(:event).where(events:{:start_date => startDate..endDate}).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #       locations = EventLocation.where(country: _europian_union).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, startDate).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #     end
          #   else
          #     if zipcode.nil?
          #       # locations = EventLocation.where(country: country).joins(:event).where(events:{:start_date => startDate..endDate}).order('events.start_date asc').page(page).per(limit)
          #       locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, startDate).order('events.start_date asc').page(page).per(limit)
          #     else
          #       # locations = EventLocation.where(country: country).joins(:event).where(events:{:start_date => startDate..endDate}).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #       locations = EventLocation.where(country: country).joins(:event).where("? >= events.start_date AND ? <= events.end_date", startDate, startDate).near(zipcode, radius).order('events.start_date asc').page(page).per(limit)
          #     end
          #   end
          #
          # end

          if !locations.empty?
            locations.each do |location|
              events << location.event
            end
            # events.sort! { |a,b| a.registration_opening_date <=> b.registration_opening_date}
          end

          if !events.empty?
            response = { status: 200, message: "#{events.count} Event(s) Found", content: Entities::Events.represent(events, current_user: current_user) }
          else
            response = { status: 200, message: 'Events Not Found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'events/my' do
      params do
        requires :type, type: Integer, values: 0..3
        requires :page, type: Integer
        requires :limit, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          events = []
          page = params[:page]
          limit = params[:limit]
          startDate = DateTime.now.midnight
          startDate = startDate - 2.day
          endDate = DateTime.now.midnight
          endDate = endDate - 2.day

          case params[:type]
          when 0 # me as organizer
            events = Event.joins("LEFT JOIN event_organizers ON event_organizers.event_id = events.id").joins("LEFT JOIN event_instructors ON events.id = event_instructors.event_id").joins("LEFT JOIN event_participants ON events.id = event_participants.event_id").where("event_organizers.user_id=? OR event_instructors.user_id=? OR event_participants.user_id=? AND event_participants.status=?", current_user.id, current_user.id, current_user.id, EventParticipant.statuses[:going]).where("end_date >= ?", endDate).order(start_date: :asc, id: :asc).distinct.page(page).per(limit)
            # events = Event.joins(:event_organizer, :event_instructors, :event_participants).where("event_organizers.user_id=? OR event_instructors.user_id=? OR event_participants.user_id=?", current_user.id, current_user.id, current_user.id).order(start_date: :asc).page(page).per(limit)
            # events = Event.joins(:event_organizer).where(event_organizers:{user_id: current_user.id}).or(Event.joins(:event_instructors).where(event_instructors:{user_id: current_user.id})).or(Event.joins(:event_participants).where(event_participants:{user_id: current_user.id})).order(start_date: :asc).page(page).per(limit)
            # SELECT  "events".* FROM "events"  FULL OUTER JOIN "event_organizers" ON "event_organizers"."event_id" = "events"."id" FULL OUTER JOIN "event_instructors" ON "event_instructors"."event_id" = "events"."id" FULL OUTER JOIN "event_participants" ON "event_participants"."event_id" = "events"."id" WHERE (event_organizers.user_id=65 OR event_instructors.user_id=65 OR event_participants.user_id=65)  ORDER BY "events"."start_date" ASC

          when 1 # me as organizer
            events = Event.joins(:event_organizer).where("events.end_date >= ?", endDate).where(event_organizers:{user_id: current_user.id}).order(start_date: :asc, id: :asc).page(page).per(limit)

          when 2 # me as instructor
            events = Event.joins(:event_instructors).where("events.end_date >= ?", endDate).where(event_instructors:{user_id: current_user.id}).order(start_date: :asc, id: :asc).page(page).per(limit)

          when 3 # me as participant
            events = Event.joins(:event_participants).where("events.end_date >= ?", endDate).where(event_participants:{user_id: current_user.id, status: EventParticipant.statuses[:going]}).order(start_date: :asc, id: :asc).page(page).per(limit)
          end

          if !events.empty?
            response = { status: 200, message: "#{events.count} Event(s) Found", content: Entities::Events.represent(events, current_user: current_user) }
          else
            response = { status: 200, message: 'Events Not Found', content: nil }
          end
        end

        return response
      end
    end

    # Get master Category sets
    namespace 'events/categories/:id' do
      params do
        requires :id, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          parent_id = params[:id] === 0 ? nil : params[:id]
          categories = EventCategory.where(parent_id: parent_id)

          if !categories.empty?
            response = { status: 200, message: 'Categories Found', content: Entities::Events::EventCategory.represent(categories) }
          else
            response = { status: 200, message: 'No Results', content: nil }
          end

        end

        return response
      end
    end

    # event CRUD
    namespace 'event/:id' do
      params do
        requires :id, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          event = Event.find_by(id: params[:id])
          if !event.nil?
            response = { status: 200, message: 'Event Found', content: Entities::Event.represent(event, current_user: current_user) }
          else
            response = { status: 200, message: 'Event Not Found', content: nil }
          end
        end

        return response
      end

      params do
        requires :title, type: String
        requires :description, type: String
        requires :startDate, type: DateTime
        requires :endDate, type: DateTime
        optional :openingDate, type: DateTime
        optional :closingDate, type: DateTime
        optional :url, type: String
        requires :street, type: String
        requires :state, type: String
        requires :city, type: String
        requires :country, type: String
        requires :zipcode, type: String
        requires :latitude, type: BigDecimal
        requires :longitude, type: BigDecimal
        # requires :pricing, type: JSON
        optional :instructors, type: JSON do
          requires :id, type: Integer
          requires :type, type: Integer
        end
        optional :pricings, type: JSON do
          requires :title, type: String
          requires :price, type: String
        end
        requires :categories, type: JSON do
          requires :id, type: Integer
        end
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: '' }
        authenticate_user
        if authenticated?

          event = Event.new(
          :title => params[:title],
          :description => params[:description],
          :start_date => params[:startDate],
          :end_date => params[:endDate],
          :registration_opening_date => params[:openingDate],
          :registration_closing_date => params[:closingDate],
          :url => params[:url].nil? ? "" : params[:url],
          :status => Event.statuses[:open]
          )

          # add location
          location_add_success = true
          location = EventLocation.new(
          :event_id => event.id,
          :street => params[:street].downcase,
          :state => params[:state].downcase,
          :city => params[:city].downcase,
          :country => params[:country].downcase,
          :zipcode => params[:zipcode].downcase,
          :latitude => params[:latitude],
          :longitude => params[:longitude]
          )
          event.event_location = location

          # mapping event categories
          categories_add_success = true
          new_category_mappings = []
          params[:categories].each do |category|
            extcategory = EventCategory.find_by(id: category.id)
            if !extcategory.nil?
              newcategory = EventCategoryMapping.new(
              :event_id => event.id,
              :event_category_id => extcategory.id
              )

              extmapping = EventCategoryMapping.find_by(event_id: event.id, event_category_id: extcategory.id)
              if extmapping.nil?
                new_category_mappings << newcategory
              end
            end
          end
          event.event_category_mappings = new_category_mappings

          if event.save

            meta_error_message = nil



            # if location.save
            #   location_add_success = true
            # else
            #   meta_error_message = "Location record not created"
            # end

            # add instructors
            instructors_add_success = false
            if !params[:instructors].nil?
              if params[:instructors].select {|t| t.type == EventInstructor.join_types[:primary]}.count == 1
                params[:instructors].each do |instructor|
                  instructors_add_success = false
                  user = User.find_by(id: instructor.id)
                  if !user.nil?
                    eveinst = EventInstructor.new(
                    :event_id => event.id,
                    :user_id => user.id,
                    :join_type => instructor.type
                    )
                    if eveinst.save
                      instructors_add_success = true
                    else
                      meta_error_message = "Instructor record not created"
                      break
                    end
                  else
                    meta_error_message = "Instructor not found - #{instructor.id}"
                    break
                  end
                end
              else
                meta_error_message = "There can only be one primary instructor for an event"
              end
            else
              instructors_add_success = true
            end

            # add organizer <- current user as organizer
            organizer_add_success = false
            eveorganizer = EventOrganizer.new(
            :event_id => event.id,
            :user_id => current_user.id
            )
            if eveorganizer.save
              organizer_add_success = true
            else
              meta_error_message = "Organizer record not created"
            end



            # add event pricings
            pricings_add_success = false
            if !params[:pricings].nil?
              params[:pricings].each do |pricing|
                pricings_add_success = false
                newpricing = EventPricing.new(
                :event_id => event.id,
                :title => pricing.title,
                :description => pricing.description,
                :price => pricing.price
                )

                if newpricing.save
                  pricings_add_success = true
                else
                  meta_error_message = "Pricing record not created for #{pricing.title}"
                  break
                end
              end
            else
              pricings_add_success = true
            end


            # set event creator a participant
            participant_add_succcess = true
            # participant = EventParticipant.new(
            #   :event_id => event.id,
            #   :user_id => current_user.id,
            #   :status => EventParticipant.statuses[:going]
            # )
            # if participant.save
            #   participant_add_succcess = true
            # else
            #   meta_error_message = "Participant record not created"
            # end

            if instructors_add_success && organizer_add_success && categories_add_success && location_add_success && pricings_add_success && participant_add_succcess
              response = { status: 201, message: 'Success', content: Entities::Event.represent(event, current_user: current_user) }
            else
              # rolling back
              EventOrganizer.where(event_id: event.id).delete_all
              EventInstructor.where(event_id: event.id).delete_all
              EventCategoryMapping.where(event_id: event.id).delete_all
              EventLocation.where(event_id: event.id).delete_all
              EventPricing.where(event_id: event.id).delete_all
              EventParticipant.where(event_id: event.id).delete_all
              event.destroy
              response = { status: 409, message: meta_error_message, content: nil }
            end
          else
            response = { status: 409, message: event.errors.messages, content: nil }
          end
        end

        return response
      end

      params do
        requires :id, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          event = Event.find_by(id: params[:id])
          if !event.nil?

            if event.event_organizer.user_id === current_user.id

              participants = event.event_participants
              if !participants.empty?
                updated = event.update(status: Event.statuses[:canceled])
                if updated
                  response = { status: 200, message: 'Event canceled', content: nil }
                else
                  response = { status: 400, message: 'Failed to cancel event', content: nil }
                end
              else
                if event.destroy

                  response = { status: 200, message: 'Event deleted', content: nil }
                else
                  response = { status: 400, message: 'Failed to remove the event', content: nil }
                end
              end
            else
              response = { status: 403, message: 'You are not the event organizer', content: nil }
            end
          else
            response = { status: 200, message: 'Event not found', content: nil }
          end
        end

        return response
      end

    end

    namespace 'event/:id/join' do
      params do
        requires :id, type: Integer
        requires :action, type: Integer
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          event = Event.find_by(id: params[:id])
          if !event.nil?

            extparticipant = EventParticipant.find_by(event_id: event.id, user_id: current_user.id)

            if extparticipant.nil?

              participant = EventParticipant.new(
              :event_id => event.id,
              :user_id => current_user.id,
              :status => params[:action]
              )

              if participant.save
                response = { status: 201, message: 'Joined the event', content: Entities::Event.represent(event, current_user: current_user) }
              else
                response = { status: 409, message: 'Faild to join the event', content: nil }
              end
            else
              update = false
              case params[:action]
              when EventParticipant.statuses[:going]
                update = extparticipant.update(:status => EventParticipant.statuses[:going])
              when EventParticipant.statuses[:maybe]
                update = extparticipant.update(:status => EventParticipant.statuses[:maybe])
              when EventParticipant.statuses[:notgoing]
                update = extparticipant.update(:status => EventParticipant.statuses[:notgoing])
              else
                update = extparticipant.update(:status => EventParticipant.statuses[:unknown])
              end

              if update
                response = { status: 200, message: 'Status updated', content: Entities::Event.represent(event, current_user: current_user) }
              else
                response = { status: 409, message: 'Faild to update the status', content: nil }
              end

            end
          else
            response = { status: 404, message: 'Event not found', content: nil }
          end
        end

        return response
      end
    end

    helpers do

      # def get_events_by_zipcode(zipcode, radius, page, limit)
      #   events = []
      #   locations = EventLocation.near(zipcode, radius).page(page).per(limit)
      #   locations.each do |location|
      #     events << location.event
      #   end
      #   return events
      # end

    end

  end
end
