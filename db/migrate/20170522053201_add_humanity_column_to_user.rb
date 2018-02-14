class AddHumanityColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :humanity, :integer
  end
end
