class AddPriorityToSectionsAndBannerToPublication < ActiveRecord::Migration
  def up
    add_column :savvy_essential_publication_sections, :position, :integer, :default => 0
    add_column :savvy_essential_publications, :rich_file_id, :integer
  end
  def down
		remove_column :savvy_essential_publication_sections, :position
		remove_column :savvy_essential_publications, :rich_file_id
  end
end
