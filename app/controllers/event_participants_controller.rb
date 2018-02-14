class EventParticipantsController < InheritedResources::Base

  private

    def event_participant_params
      params.require(:event_participant).permit()
    end
end

