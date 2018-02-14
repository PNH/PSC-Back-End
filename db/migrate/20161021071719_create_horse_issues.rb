class CreateHorseIssues < ActiveRecord::Migration
  def change
    create_table :horse_issues do |t|
      t.timestamps null: false
      t.belongs_to :horse, foreign_key: true
      t.belongs_to :issue, foreign_key: true
    end
  end
end
