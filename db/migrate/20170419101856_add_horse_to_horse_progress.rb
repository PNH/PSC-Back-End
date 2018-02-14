class AddHorseToHorseProgress < ActiveRecord::Migration
  def change
    add_reference :horse_progresses, :horse, foreign_key: true
  end
end
