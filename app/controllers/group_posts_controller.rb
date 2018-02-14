class GroupPostsController < InheritedResources::Base

  private

    def group_post_params
      params.require(:group_post).permit(:user, :content, :status)
    end
end
