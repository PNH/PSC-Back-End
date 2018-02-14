class EventInstructor < ActiveRecord::Base

  belongs_to :event
  belongs_to :user

  enum join_type: [
    :assisting,
    :primary,
  ]

  # validate :has_only_one_primary
  # def has_only_one_primary
  #   byebug
  #   _pry_instructors = EventInstructor.find_by(event_id: self.event_id, join_type: EventInstructor.join_types[:primary])
  #   if !_pry_instructors.nil?
  #     errors.add("EventInstructor", "- should have only one primary instructor")
  #   end
  # end

end
