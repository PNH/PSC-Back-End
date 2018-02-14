class HorseProgressesController < InheritedResources::Base

  private

    def horse_progress_params
      params.require(:horse_progress).permit()
    end
end

