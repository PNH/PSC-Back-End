class LevelChecklistsController < InheritedResources::Base

  private

    def level_checklist_params
      params.require(:level_checklist).permit(:level_id, :title, :content, :status)
    end
end

