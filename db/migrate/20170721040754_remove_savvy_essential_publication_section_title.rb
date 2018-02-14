class RemoveSavvyEssentialPublicationSectionTitle < ActiveRecord::Migration
  def up
		remove_column :savvy_essential_publication_sections, :title
  end
  def down
		add_column :savvy_essential_publication_sections, :title, :string
  end
end
