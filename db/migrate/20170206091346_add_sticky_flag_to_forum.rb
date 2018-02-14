class AddStickyFlagToForum < ActiveRecord::Migration
def change
    change_table :forums do |t|
      t.boolean :is_sticky, default: true
    end
  end
end
