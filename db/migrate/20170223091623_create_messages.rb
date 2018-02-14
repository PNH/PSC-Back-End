class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.belongs_to :user, foreign_key: true
      t.boolean :status
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
