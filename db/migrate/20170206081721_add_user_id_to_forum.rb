class AddUserIdToForum < ActiveRecord::Migration
  def change
    change_table :forums do |t|
      t.integer :user_id
    end
  end
end
