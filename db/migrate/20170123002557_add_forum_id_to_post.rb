class AddForumIdToPost < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.belongs_to :forum, foreign_key: true
    end
  end
end
