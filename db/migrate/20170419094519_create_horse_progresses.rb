class CreateHorseProgresses < ActiveRecord::Migration
  def change
    create_table :horse_progresses do |t|
      t.belongs_to :wall, index: true, foreign_key: true
      t.text :note
    end
  end
end
