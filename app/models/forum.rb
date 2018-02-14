class Forum < ActiveRecord::Base
  # include PgSearch
  # multisearchable :against => [:title], :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  self.table_name = 'forum_topics'

  acts_as_tree
  acts_as_paranoid
  belongs_to :user
  has_many :sub_forums, foreign_key: 'parent_id'
  scope :forums, -> { where('parent_id IS NULL').all }
  scope :recent_forums, -> (limit) { where('parent_id IS NULL').order(created_at: :desc).first(limit) }

  validates :title, presence: true

  before_destroy :check_for_sub_forums

  def forum_count
    Forum.where(id: self.id).joins(sub_forums: [:forum_topics]).count
  end

  def post_count
    Forum.where(id: self.id).joins(sub_forums: [forum_topics: [:forum_posts]]).count
  end

  def comment_count
    Forum.where(id: self.id).joins(sub_forums: [forum_topics: [forum_posts: [:forum_post_comment]]]).count
  end

  def user_count
    Forum.where(id: self.id).joins(sub_forums: [forum_topics: [forum_posts: [:user]]]).count
  end

  def voices
    count = 0
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where ft.id=#{self.id} and ft.user_id=u.id group by u.id").count
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=#{self.id} and f.id=fp.forum_id and fp.user_id=u.id group by u.id").count
    # count += (User.find_by_sql "select distinct (u.id), u.first_name as \"users\" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=#{self.id} and f.id=fp.forum_id and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id").count
    return count
  end

end

private

def check_for_sub_forums
  if sub_forums.count > 0
    self.errors[:base] << "Delete Sub-Forums before deleting the parent forum"
    return false
  end
end

# select distinct (u.id), u.first_name as "users" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where ft.id=59 and ft.user_id=u.id;

# select distinct (u.id), u.first_name as "users" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=59 and f.id=fp.forum_id and fp.user_id=u.id;

# select distinct (u.id), u.first_name as "users" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=59 and f.id=fp.forum_id and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id;



# select distinct (u.id), u.first_name as "users" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where ft.id=44 and ft.user_id=u.id;
#
# select distinct (u.id), u.first_name as "users" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=44 and f.id=fp.forum_id and fp.user_id=u.id;
#
# select distinct (u.id), u.first_name as "users" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where f.forum_topic_id=44 and f.id=fp.forum_id and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id;
