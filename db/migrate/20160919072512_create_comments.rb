class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :user, foreign_key: true
      t.text :message
      t.boolean :status
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
