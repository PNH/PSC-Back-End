class CreateEvents < ActiveRecord::Migration
  def change
    # house cleaning - previously added tables
    drop_table :event_prices
    drop_table :event_users
    drop_table :events
    drop_table :event_categories

    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :registration_opening_date
      t.datetime :registration_closing_date
      t.string :url
      t.integer :status, index: true
      t.timestamps null: false
    end
  end
end
