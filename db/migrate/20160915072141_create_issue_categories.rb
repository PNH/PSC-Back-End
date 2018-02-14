class CreateIssueCategories < ActiveRecord::Migration
  def change
    create_table :issue_categories do |t|
      t.string :title
      t.boolean :status
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.belongs_to :goal, foreign_key: true
    end
  end
end
