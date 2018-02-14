class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :title
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.belongs_to :savvy, foreign_key: true
      t.belongs_to :issue_category, foreign_key: true
    end
  end
end
