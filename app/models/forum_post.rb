class ForumPost < ActiveRecord::Base
  has_many :forum_post_comment, :dependent => :destroy
  has_many :forum_post_attachment, :dependent => :destroy
  belongs_to :user
  belongs_to :forum_topic, class_name: 'ForumTopic', foreign_key: 'forum_id'
  has_many :forum_post_like, :dependent => :destroy

  # runtime attrs
  attr_accessor :likes
  attr_accessor :liked
  attr_accessor :isowner
  attr_accessor :commentcount

  def comment_count
    self.forum_post_comments.count
  end

  def user_count
    ForumPost.where(id: self.id).joins(forum_post_comments: [:user]).count
  end

end
