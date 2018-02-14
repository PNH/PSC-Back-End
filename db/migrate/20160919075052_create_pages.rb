class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
      t.string :title
      t.string :slug
      t.string :url
      t.text :description
      t.boolean :status
    end
  end
end
