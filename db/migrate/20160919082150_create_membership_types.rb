class CreateMembershipTypes < ActiveRecord::Migration
  def change
    create_table :membership_types do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.integer :billing_frequency
      t.decimal :tax
      t.decimal :cost
      t.boolean :status
    end
  end
end
