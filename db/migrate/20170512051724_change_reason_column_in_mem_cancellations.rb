class ChangeReasonColumnInMemCancellations < ActiveRecord::Migration
  def change
    remove_column :membership_cancellations, :reason
    add_column :membership_cancellations, :reason, :integer
  end
end
