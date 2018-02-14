class AddPersonaToHorse < ActiveRecord::Migration
  def change
  	add_reference :horses, :goal, foreign_key: true
  end
end
