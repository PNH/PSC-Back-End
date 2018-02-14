# frozen_string_literal: true
class AddHorsetoItsBadges < ActiveRecord::Migration
  def change
    change_table :horse_badges do |t|
      t.belongs_to :horse, foreign_key: true
    end
  end
end
