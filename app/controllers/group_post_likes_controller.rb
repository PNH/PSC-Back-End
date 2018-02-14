class GroupPostLikesController < InheritedResources::Base

  private

    def group_post_like_params
      params.require(:group_post_like).permit(:group_id, :post_id, :user_id, :status)
    end
end

