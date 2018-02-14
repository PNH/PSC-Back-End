class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.string :name
      t.string :short_description
      t.text :description
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
