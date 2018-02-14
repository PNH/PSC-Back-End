class AddItemIdToMembership < ActiveRecord::Migration
  def change
    change_table :membership_types do |t|
      t.string :item_id
    end
  end
end
