# frozen_string_literal: true
class UserRegistration < ActiveRecord::Migration
  def change
    change_table :membership_types do |t|
      t.integer :level
      t.text :benefits
    end
    change_table :membership_details do |t|
      t.integer :level
      t.integer :billing_address_id
    end
    add_foreign_key :membership_details, :addresses, column: :billing_address_id
    change_table :addresses do |t|
      t.string :street2
    end
  end
end
