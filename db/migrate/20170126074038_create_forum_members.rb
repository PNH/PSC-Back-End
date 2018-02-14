class CreateForumMembers < ActiveRecord::Migration
  def change
    create_table :forum_members do |t|
      t.belongs_to :forum, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
