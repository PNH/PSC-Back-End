class CreateMemberminutes < ActiveRecord::Migration
  def change
    create_table :memberminutes do |t|
      t.string :title
      t.timestamps null: false
      t.date :publish_date
      t.datetime :deleted_at, index: true
      t.string :short_description
      t.text :description
      t.boolean :status
    end
  end
end
