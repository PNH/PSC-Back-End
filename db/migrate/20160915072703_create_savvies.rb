class CreateSavvies < ActiveRecord::Migration
  def change
    create_table :savvies do |t|
      t.string :title
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.belongs_to :level, foreign_key: true
    end
  end
end
