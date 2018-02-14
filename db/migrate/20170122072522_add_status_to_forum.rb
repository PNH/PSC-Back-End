class AddStatusToForum < ActiveRecord::Migration
  def change
    change_table :forums do |t|
      t.boolean :status
    end
  end
end
