class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :title
      t.string :country
      t.string :symbol
      t.timestamps null: false
    end
  end
end
