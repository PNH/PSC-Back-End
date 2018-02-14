class CreateMembershipDetails < ActiveRecord::Migration
  def change
    create_table :membership_details do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :user, foreign_key: true
      t.belongs_to :membership_type, foreign_key: true
      t.integer :billing_frequency
      t.decimal :tax
      t.decimal :cost
      t.decimal :total
      t.date :joined_date
      t.boolean :status
    end
  end
end
