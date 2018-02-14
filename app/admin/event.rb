ActiveAdmin.register Event do

  menu false
  filter :title_cont, as: :string, label: 'By Title'
  filter :start_date
  filter :end_date

  _datetime_format = "%m/%d/%Y"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :title, :description, :start_date, :start_time, :end_date, :end_time, :registration_opening_date, :registration_opening_time, :registration_closing_date, :registration_closing_time, :url, :status,
  event_pricings_attributes: [:id, :title, :description, :price, :_destroy],
  event_category_mappings_attributes:[:id, :event_category_id, :_destroy],
  event_instructors_attributes:[:id, :user_id, :join_type, :_destroy],
  event_location_attributes:[:id, :street, :state, :city, :country, :zipcode, :latitude, :longitude, :_destroy]
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  index do
    # column :id
    column :title
    # column :description
    # column('Event (Start - End)') do |event|
    #   "#{event.start_date.strftime(_datetime_format)} - #{event.end_date.strftime(_datetime_format)}"
    # end
    # column('Registration (Opening - Closing)') do |event|
    #   "#{event.registration_opening_date.strftime(_datetime_format)} - #{event.registration_closing_date.strftime(_datetime_format)}"
    # end
    column :start_date do |event| event.start_date.strftime("%m/%d/%Y") end
    column :end_date do |event| event.end_date.strftime("%m/%d/%Y") end
    # column :registration_opening_date do |event| event.registration_opening_date.strftime("%m/%d/%Y") end
    # column :registration_closing_date do |event| event.registration_closing_date.strftime("%m/%d/%Y") end
    # column :url
    column('Organizer') do |event|
      if !event.event_organizer.nil? && !event.event_organizer.user.nil?
        link_to "#{event.event_organizer.user.first_name} #{event.event_organizer.user.last_name}", "event_organizers/#{event.event_organizer.id}"
      else
        "Deleted or Not Assigned"
      end
    end
    column('Location') do |event|
      if !event.event_location.nil?
        link_to "#{event.event_location.country}, #{event.event_location.state}, #{event.event_location.city}", "event_locations/#{event.event_location.id}"
      else
        "Not Assigned"
      end
    end
    # column('Categories') do |event|
    #   link_to event.event_category_mappings.count, "events/#{event.id}/event_category_mappings"
    # end
    # column('Instructors') do |event|
    #   link_to event.event_instructors.count, "events/#{event.id}/event_instructors"
    # end
    # column('Pricings') do |event|
    #   link_to event.event_pricings.count, "events/#{event.id}/event_pricings"
    # end
    column('Participants') do |event|
      # link_to event.event_participants.count, "events/#{event.id}/event_participants"
      event.event_participants.count
    end

    column :status
    actions
  end

  form do |f|
    if f.object.new_record?
      f.object.status = 1
    end
    f.inputs do
      f.input :title
      f.input :description, as: :rich, config: { width: '76%', height: '400px' }
      f.inputs do
        f.input :start_date, as: :datepicker
        # f.input :start_time, as: :time_picker
      end
      f.inputs do
        f.input :end_date, as: :datepicker
        # f.input :end_time, as: :time_picker
      end
      f.inputs do
        f.input :registration_opening_date, as: :datepicker
        # f.input :registration_opening_time, as: :time_picker
      end
      f.inputs do
        f.input :registration_closing_date, as: :datepicker
        # f.input :registration_closing_time, as: :time_picker
      end
      f.input :url
      f.input :status
    end

    # unless f.object.new_record?
      f.inputs do
        if f.object.new_record? && f.object.event_location.nil?
          f.object.event_location = EventLocation.new
        end
        f.has_many :event_location, heading: 'Location', allow_destroy: false, new_record: f.object.event_location.nil? ? 'Add' : false do |pf|
          pf.input :country, include_blank: true, as: :select2, collection: []
          # ISO3166::Country.translations.collect{ |cnt|
          #   [cnt[1], cnt[0].downcase]
          # }
          if f.object.new_record?
            pf.input :state, as: :select2, collection: [] #, as: :autocomplete, url: autocomplete_state_admin_events_path
          else
            session[:event_location]= f.object.event_location
            if object.event_location.state && object.event_location.state.length > 2
              pf.input :state, as: :select2, collection: []
            else
              pf.input :state, as: :select2, collection: [] #, :input_html => {:value => CS.states(object.event_location.country.to_sym)[object.event_location.state.to_sym]}
            end
          end
          pf.input :city
          pf.input :street
          pf.input :zipcode
          pf.input :latitude
          pf.input :longitude
          render 'map'
        end
      end
    # end

    # unless !f.object.new_record?
      f.inputs do
        f.has_many :event_category_mappings, heading: 'Sub-Categories', allow_destroy: true, new_record: 'Add' do |pf|
          pf.input :event_category_id, label: 'Sub-Category', as: :select,  collection: EventCategory.where().not(parent_id: nil).map {|c| [c.title.to_s, c.id]}
        end
      end
    # end

    # unless !f.object.new_record?
      f.inputs do
        f.has_many :event_pricings, heading: 'Pricings', allow_destroy: true, new_record: 'Add' do |pf|
          pf.input :title
          # pf.input :description
          pf.input :price
          # pf.button do
          #   link_to "Delete", admin_event_pricings_path(pf.object), method: "delete", class: "button" unless pf.object.new_record?
          # end
          pf.actions
        end
      end
    # end

    # unless !f.object.new_record?
      f.inputs do
        f.has_many :event_instructors, heading: 'Instructors', allow_destroy: true, new_record: 'Add' do |pf|
          pf.input :user_id, as: :select,  collection: User.where(is_instructor: true).map {|u| ["#{u.first_name} #{u.last_name}", u.id]}
          pf.input :join_type
        end
      end
    # end
      f.semantic_errors *f.object.errors.keys

    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Event')
      else
        f.action(:submit, label: 'Update Event')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  after_filter :assign_organizer, only: [:create]

  before_save do |event|
    # require 'date'
    event.event_location.country = !event.event_location.country.nil? ? event.event_location.country.downcase : nil
    event.event_location.state = !event.event_location.state.nil? ? event.event_location.state.downcase : nil
    # byebug

    event.start_date = !event.start_date.nil? ? event.start_date.beginning_of_day : nil
    event.end_date = !event.end_date.nil? ? event.end_date.beginning_of_day : nil
    event.registration_opening_date = !event.registration_opening_date.nil? ? event.registration_opening_date.beginning_of_day : nil
    event.registration_closing_date = !event.registration_closing_date.nil? ? event.registration_closing_date.beginning_of_day : nil
    # event.start_date = !event.start_time.empty? ? DateTime.parse("#{_make_datetime_str(event.start_date)} #{event.start_time}:00").to_s : event.start_date
    # event.end_date = !event.end_time.empty? ? DateTime.parse("#{_make_datetime_str(event.end_date)} #{event.end_time}:00").to_s : event.end_date
    # event.registration_opening_date = !event.registration_opening_time.empty? ? DateTime.parse("#{_make_datetime_str(event.registration_opening_date)} #{event.registration_opening_time}:00").to_s : event.registration_opening_date
    # event.registration_closing_date = !event.registration_closing_time.empty? ? DateTime.parse("#{_make_datetime_str(event.registration_closing_date)} #{event.registration_closing_time}:00").to_s : event.registration_closing_date

    # event.registration_opening_date = event.start_date
    # event.registration_closing_date = event.end_date

    # state fix
    # state_index = 0
    # CS.states(event.event_location.country).values.each_with_index do |state, index|
    #   if state == event.event_location.state
    #     state_index = index
    #     event.event_location.state = CS.states(event.event_location.country).keys[state_index]
    #     break
    #   end
    # end
    # byebug
  end

  controller do

    def _make_datetime_str(datetime)
      return "#{datetime.year}-#{datetime.month}-#{datetime.day}"
    end

    def assign_organizer
      _event_id = @event.id
      eveorganizer = EventOrganizer.new(
      :event_id => _event_id,
      :user_id => current_admin_user.id
      )
      eveorganizer.save
    end

  end

  collection_action :autocomplete_state, method: [:get] do
    if session[:event_location]
      render json: CS.states(session[:event_location]["country"])
    else
      render json: []
    end
  end

  # collection_action :autocomplete_city, method: [:get] do
  #   # byebug
  #   render json: CS.cities(CS.states('US').key(params[:state]), params[:country])
  #   # render json: CS.cities(params[:state])
  # end

end
