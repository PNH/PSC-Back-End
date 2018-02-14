class HorseProgressLogsController < InheritedResources::Base

  private

    def horse_progress_log_params
      params.require(:horse_progress_log).permit()
    end
end

