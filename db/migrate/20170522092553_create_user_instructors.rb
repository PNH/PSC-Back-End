class CreateUserInstructors < ActiveRecord::Migration
  def change
    create_table :user_instructors do |t|
      t.integer :user_id, index: true
      t.integer :instructor_id
    end
  end
end
