class GroupPostCommentsController < InheritedResources::Base

  private

    def group_post_comment_params
      params.require(:group_post_comment).permit(:user_id, :group_post, :comment, :parent_id)
    end
end

