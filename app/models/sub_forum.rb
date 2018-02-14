# frozen_string_literal: true
class SubForum < ActiveRecord::Base
  self.table_name = 'forum_topics'
  acts_as_paranoid

  belongs_to :forum, class_name: 'Forum', foreign_key: 'parent_id'
  belongs_to :user
  has_many :forum_topics, foreign_key: 'forum_topic_id'
  validates :title, presence: true

  before_destroy :check_for_forum_topics

  def forum_count
    SubForum.where(id: self.id).joins(:forum_topics).count
  end

  def post_count
    SubForum.where(id: self.id).joins(forum_topics: [:forum_posts]).count
  end

  def comment_count
    SubForum.where(id: self.id).joins(forum_topics: [forum_posts: [:forum_post_comment]]).count
  end

  def user_count
    SubForum.where(id: self.id).joins(forum_topics: [forum_posts: [:user]]).count
  end

  def stickies
    ForumTopic.where forum_topic_id: self.id, is_sticky: true
  end

  def topic_count
    ForumTopic.where(forum_topic_id: self.id).count
  end

  def voices
    count = 0
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where ft.id=#{self.id} and ft.user_id=u.id group by u.id").count
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=#{self.id} and f.id=fp.forum_id and fp.user_id=u.id group by u.id").count
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=#{self.id} and f.id=fp.forum_id and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id").count
    return count
  end

  private

  def check_for_forum_topics
    if forum_topics.count > 0
      self.errors[:base] << "Delete Forum Topics before deleting the Sub-Forum"
      return false
    end
  end

end
