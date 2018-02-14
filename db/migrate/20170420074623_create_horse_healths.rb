class CreateHorseHealths < ActiveRecord::Migration
  def change
    create_table :horse_healths do |t|
      t.belongs_to :wall, index: true, foreign_key: true
      t.references :horse
      t.string :provider
      t.date :visit
      t.date :next_visit
      t.integer :visit_type
      t.text :note
      t.text :assessment
      t.text :treatment_outcome
      t.text :post_treatment_care
      t.text :recommendations
    end
  end
end
