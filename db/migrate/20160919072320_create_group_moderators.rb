class CreateGroupModerators < ActiveRecord::Migration
  def change
    create_table :group_moderators do |t|
      t.belongs_to :group, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
