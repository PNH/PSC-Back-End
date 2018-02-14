class DropPreviousTouchstones < ActiveRecord::Migration
  def change
		drop_table :touchstone_resources
		drop_table :touchstone_sections
		drop_table :touchstones
		drop_table :touchstone_categories
  end
end
