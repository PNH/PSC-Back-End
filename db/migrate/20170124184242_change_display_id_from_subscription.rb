class ChangeDisplayIdFromSubscription < ActiveRecord::Migration
  def change
    change_column :subscriptions, :display_id, :string
  end
end
