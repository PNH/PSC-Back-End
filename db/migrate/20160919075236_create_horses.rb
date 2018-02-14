class CreateHorses < ActiveRecord::Migration
  def change
    create_table :horses do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.belongs_to :user, foreign_key: true
      t.integer :sex
    end
  end
end
