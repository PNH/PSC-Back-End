class EventParticipant < ActiveRecord::Base

  belongs_to :event
  belongs_to :user

  enum status: {
    going: 1,
    maybe: 2,
    notgoing: 3,
    unknown: -1
  }

  def self.participation(event_id, user_id)
    return EventParticipant.find_by(event_id: event_id, user_id: user_id)
  end

end
