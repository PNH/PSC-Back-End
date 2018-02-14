class AddHorseGeneralInfo < ActiveRecord::Migration
  def change
    change_table :horses do |t|
      t.integer :horsenality
      t.belongs_to :level, foreign_key: true
      t.date :birthday
      t.string :color
      t.decimal :height
      t.decimal :weight
      t.text :bio
    end
  end
end
