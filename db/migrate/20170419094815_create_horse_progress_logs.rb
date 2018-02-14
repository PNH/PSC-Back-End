class CreateHorseProgressLogs < ActiveRecord::Migration
  def change
    create_table :horse_progress_logs do |t|
      t.belongs_to :horse_progress, index: true, foreign_key: true
      t.references :level
      t.references :savvy
      t.integer :time
    end
  end
end
