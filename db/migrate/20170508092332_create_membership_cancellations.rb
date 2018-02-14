class CreateMembershipCancellations < ActiveRecord::Migration
  def change
    create_table :membership_cancellations do |t|
      t.references :user, index: true, foreign_key: true
      t.string :reason
      t.text :note
      t.timestamps null: false
    end
  end
end
