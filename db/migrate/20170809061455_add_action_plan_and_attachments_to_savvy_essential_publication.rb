class AddActionPlanAndAttachmentsToSavvyEssentialPublication < ActiveRecord::Migration
  def up
    # rich_attachment_id as `Action Plan`
    add_column :savvy_essential_publications, :rich_attachment_id, :integer
    # additional content as an url
    add_column :savvy_essential_publications, :additional_content , :string
  end
  def down
		remove_column :savvy_essential_publications, :rich_attachment_id
		remove_column :savvy_essential_publications, :additional_content
  end
end
