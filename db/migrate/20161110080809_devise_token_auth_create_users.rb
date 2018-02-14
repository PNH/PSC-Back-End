# frozen_string_literal: true
class DeviseTokenAuthCreateUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :provider, null: false, default: 'email'
      t.string :uid, null: false, default: ''
      t.json :tokens
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable
    end
    # add_index :users, [:uid, :provider], unique: true
  end
end
