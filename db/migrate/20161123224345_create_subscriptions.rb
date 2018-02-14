class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :user, foreign_key: true
      t.integer :currency
      t.belongs_to :address, foreign_key: true
      t.belongs_to :subscrpt_credit_card, foreign_key: true
      t.boolean :is_parent
      t.integer :entity_id
      t.integer :external_id
      t.integer :display_id
      t.decimal :price
      t.string :membership_level
      t.string :membership_cycle
      t.date :start_date
      t.date :end_date
      t.boolean :is_auto_renewal
      t.boolean :is_active
      t.boolean :is_lifetime
      t.boolean :is_promotion
      t.integer :product
      t.integer :charge_status
      t.date :inactive_date
      t.string :inactive_reason
    end
  end
end
