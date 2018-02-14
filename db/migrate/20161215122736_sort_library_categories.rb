class SortLibraryCategories < ActiveRecord::Migration
  def change
    change_table :llcategories do |t|
      t.integer :position
    end
  end
end
