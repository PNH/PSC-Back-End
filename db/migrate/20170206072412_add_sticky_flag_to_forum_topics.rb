class AddStickyFlagToForumTopics < ActiveRecord::Migration
  def change
    def self.up
      add_column :forum_topics, :is_sticky, :boolean, :default => true
    end

    def self.down
      remove_column :forum_topics, :is_sticky
    end
  end
end
