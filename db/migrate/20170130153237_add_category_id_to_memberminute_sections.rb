class AddCategoryIdToMemberminuteSections < ActiveRecord::Migration
  def change
    change_table :memberminute_sections do |t|
      t.integer :kind
    end
  end
end
