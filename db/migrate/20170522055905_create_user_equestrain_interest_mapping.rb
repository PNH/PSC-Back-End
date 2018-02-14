class CreateUserEquestrainInterestMapping < ActiveRecord::Migration
  def change
    create_table :user_equestrain_interest_mappings do |t|
      t.integer :user_id, index: true
      t.integer :equestrain_interest_id
    end
  end
end
