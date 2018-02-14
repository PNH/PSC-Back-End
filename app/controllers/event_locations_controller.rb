class EventLocationsController < InheritedResources::Base

  private

    def event_location_params
      params.require(:event_location).permit()
    end
end

