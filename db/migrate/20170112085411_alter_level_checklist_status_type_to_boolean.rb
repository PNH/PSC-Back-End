class AlterLevelChecklistStatusTypeToBoolean < ActiveRecord::Migration
  def change
    def up
      change_column :level_checklists, :status, :boolean
    end

    def down
      change_column :level_checklists, :status, :integer
    end
  end
end
