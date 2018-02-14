class GroupPostAttachmentsController < InheritedResources::Base

  private

    def group_post_attachment_params
      params.require(:group_post_attachment).permit(:group_post_id, :rich_file_id, :status)
    end
end

