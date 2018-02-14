class CreateMemberminuteSections < ActiveRecord::Migration
  def change
    create_table :memberminute_sections do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.string :title
      t.text :description
      t.boolean :status
      t.belongs_to :memberminute, foreign_key: true
    end
  end
end
