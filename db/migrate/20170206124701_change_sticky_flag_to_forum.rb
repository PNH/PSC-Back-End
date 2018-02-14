class ChangeStickyFlagToForum < ActiveRecord::Migration
  def change
    change_column :forums, :is_sticky, :boolean, :default => false
  end
end
