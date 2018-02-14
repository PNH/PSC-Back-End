class EventOrganizersController < InheritedResources::Base

  private

    def event_organizer_params
      params.require(:event_organizer).permit()
    end
end

