# frozen_string_literal: true
class LevelForUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.belongs_to :level, foreign_key: true
    end
  end
end
