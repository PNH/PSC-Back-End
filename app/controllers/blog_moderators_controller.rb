class BlogModeratorsController < InheritedResources::Base

  private

    def blog_moderator_params
      params.require(:blog_moderator).permit()
    end
end

