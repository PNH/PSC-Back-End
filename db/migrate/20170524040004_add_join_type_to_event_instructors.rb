class AddJoinTypeToEventInstructors < ActiveRecord::Migration
  def change
    add_column :event_instructors, :join_type, :integer, :default => 0
  end
end
