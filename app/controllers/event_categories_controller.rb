class EventCategoriesController < InheritedResources::Base

  private

    def event_category_params
      params.require(:event_category).permit()
    end
end

