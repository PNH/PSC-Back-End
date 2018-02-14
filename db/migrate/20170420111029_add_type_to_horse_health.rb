class AddTypeToHorseHealth < ActiveRecord::Migration
  def change
    add_column :horse_healths, :type, :integer
  end
end
