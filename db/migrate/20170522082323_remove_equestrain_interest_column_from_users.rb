class RemoveEquestrainInterestColumnFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :equestrain_interest
  end
end
