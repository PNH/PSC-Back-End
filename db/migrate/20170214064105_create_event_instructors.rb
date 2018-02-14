class CreateEventInstructors < ActiveRecord::Migration
  def change
    create_table :event_instructors do |t|
      t.integer :event_id, index: true
      t.integer :user_id, index: true
      t.timestamps null: false
    end
  end
end
