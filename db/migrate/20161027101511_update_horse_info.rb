# frozen_string_literal: true
class UpdateHorseInfo < ActiveRecord::Migration
  def change
    change_table :horses do |t|
      t.string :name
      t.string :age
      t.string :breed
    end
  end
end
