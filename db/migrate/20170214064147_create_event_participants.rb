class CreateEventParticipants < ActiveRecord::Migration
  def change
    create_table :event_participants do |t|
      t.integer :event_id, index: true
      t.integer :user_id, index: true
      t.integer :status
      t.timestamps null: false
    end
    add_index :event_participants, [:user_id, :status], :name => 'event_participants_user_status_index'
  end
end
