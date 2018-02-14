# frozen_string_literal: true
class CreateHorseBadges < ActiveRecord::Migration
  def change
    create_table :horse_badges do |t|
      t.belongs_to :lesson_category, foreign_key: true
      t.timestamps null: false
    end
  end
end
