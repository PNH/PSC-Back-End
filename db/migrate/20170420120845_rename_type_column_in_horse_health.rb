class RenameTypeColumnInHorseHealth < ActiveRecord::Migration
  def change
    rename_column :horse_healths, :type, :health_type

  end
end
