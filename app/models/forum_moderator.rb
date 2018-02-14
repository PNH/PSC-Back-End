class ForumModerator < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :forum_topic, class_name: 'ForumTopic', inverse_of: :moderators, foreign_key: 'forum_id'
  belongs_to :user
end
