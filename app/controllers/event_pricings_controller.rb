class EventPricingsController < InheritedResources::Base

  private

    def event_pricing_params
      params.require(:event_pricing).permit()
    end
end

