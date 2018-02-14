class EventCategoryMappingsController < InheritedResources::Base

  private

    def event_category_mapping_params
      params.require(:event_category_mapping).permit()
    end
end

