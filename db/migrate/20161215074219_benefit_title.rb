class BenefitTitle < ActiveRecord::Migration
  def change
    change_table :membership_types do |t|
      t.string :benefit_title
    end
  end
end
