class EventInstructorsController < InheritedResources::Base

  private

    def event_instructor_params
      params.require(:event_instructor).permit()
    end
end

