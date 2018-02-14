class RenameColumnTopicIdFromForum < ActiveRecord::Migration
  def change
    remove_column :forums, :topic_id
    change_table :forums do |t|
      t.belongs_to :forum_topic, foreign_key: true
    end
  end
end
