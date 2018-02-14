class CreateSubscrptCreditCards < ActiveRecord::Migration
  def change
    create_table :subscrpt_credit_cards do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :user, foreign_key: true
      t.integer :ns_id
      t.boolean :default
      t.string :name
      t.string :number
      t.string :cc_type
      t.date :expire_date
    end
  end
end
