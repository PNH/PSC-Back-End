class CreateItemCosts < ActiveRecord::Migration
  def change
    create_table :item_costs do |t|
      t.belongs_to :currency, foreign_key: true
      t.belongs_to :membership_type, foreign_key: true
      t.decimal :cost
      t.timestamps null: false
    end
  end
end
