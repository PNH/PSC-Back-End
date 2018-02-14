class ForumTopic < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title], :if => :deleted_topic?, :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  def deleted_topic?
    deleted_at != nil || sub_forum == nil  ? false : true;
  end

  acts_as_paranoid
  self.table_name = 'forums'

  belongs_to :sub_forum, class_name: 'SubForum', foreign_key: 'forum_topic_id'
  belongs_to :image, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  belongs_to :user
  has_many :moderators, inverse_of: :forum_topic, class_name: 'ForumModerator', foreign_key: 'forum_topic_id'
  has_many :users, through: :forum_moderators
  has_many :users, through: :forum_members
  has_many :forum_posts, :dependent => :destroy, foreign_key: 'forum_id'
  has_many :forum_moderators, :dependent => :destroy, foreign_key: 'forum_id'
  has_many :forum_members, :dependent => :destroy, foreign_key: 'forum_id'

  validates :title, presence: true
  validates :description, presence: true

  attr_accessor :ismember
  attr_accessor :isowner
  attr_accessor :ismoderator
  attr_accessor :membercount

  def post_count
    ForumTopic.where(id: self.id).joins(:forum_posts).count
  end

  def comment_count
    ForumTopic.where(id: self.id).joins(forum_posts: [:forum_post_comment]).count
  end

  def user_count
    ForumTopic.where(id: self.id).joins(forum_posts: [forum_post_comment: [:user]]).count
  end

  def voices
    count = 0
    post_users = (User.find_by_sql "select distinct (u.id) from forum_topics as ft, forum_posts as fp, users as u where fp.forum_id=#{self.id} and fp.user_id=u.id group by u.id")
    comment_users = (User.find_by_sql "select distinct (u.id) from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, users as u where fp.forum_id=#{self.id} and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id")
    all_users = (post_users + comment_users)
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.id=#{self.id} and f.id=fp.forum_id and fp.user_id=u.id group by u.id").count
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.id=#{self.id} and f.id=fp.forum_id and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id").count
    return all_users.uniq.count
  end

end

# select distinct (u.id) from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, users as u where fp.forum_id=46 and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id;

# select distinct (u.id) from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, users as u where ft.id=46 and fp.forum_id=ft.id or fpc.forum_post_id=fp.id and fp.forum_id=ft.id group by u.id

# select distinct (u.id) from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, users as u where fp.forum_id=46 and fp.forum_id=ft.id or fpc.forum_post_id=fp.id and fp.forum_id=ft.id group by u.id
