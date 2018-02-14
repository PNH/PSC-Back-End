class HorseHealthsController < InheritedResources::Base

  private

    def horse_health_params
      params.require(:horse_health).permit()
    end
end

