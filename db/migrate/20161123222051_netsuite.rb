class Netsuite < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :entity_id
      t.string :username
      t.integer :nr_instructor_stars
      t.boolean :is_instructor
      t.boolean :is_instructor_junior
      t.boolean :is_staff_member
      t.boolean :is_parent
      t.boolean :is_child
      t.boolean :good_standing
      t.boolean :is_disabled
      t.integer :legacy_party_id
      t.boolean :had_membership
    end

    change_table :addresses do |t|
      t.string :addrtext
      t.string :label
      t.integer :ns_id
    end
  end
end
