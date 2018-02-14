class ChangeHeignWieghtColumnsInHorses < ActiveRecord::Migration
  def change
    change_column :horses, :height, :string
    change_column :horses, :weight, :string
  end
end
