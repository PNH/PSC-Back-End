class WallSolutionmapPostsController < InheritedResources::Base

  private

    def wall_solutionmap_post_params
      params.require(:wall_solutionmap_post).permit()
    end
end

