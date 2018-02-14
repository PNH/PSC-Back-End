class AddDescriptionToMemberminuteResources < ActiveRecord::Migration
  def change
    change_table :memberminute_resources do |t|
      t.text :description
    end
  end
end
