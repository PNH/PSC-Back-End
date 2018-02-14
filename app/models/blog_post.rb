class BlogPost < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title, :summary], :if => :searchable_posts?, :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  def searchable_posts?
    status != "enable" ? false : true;
  end

  belongs_to :blog
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  has_many :blog_post_comments, :dependent => :destroy
  has_many :blog_post_attachments, :dependent => :destroy
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'thumb_id'

  has_many :blog_post_tags, dependent: :destroy
  has_many :tags, through: :blog_post_tags

  has_many :blog_post_blog_categories, dependent: :destroy
  has_many :blog_categories, through: :blog_post_blog_categories

  has_many :notifications, as: :notifiable

  enum privacy: [:everyone, :members_only]
  enum status: {enable: 1, disable: 0, pending: 2}

  validates :title, presence: true
  validates :summary, presence: true
  validates :content, presence: true
  # validates_length_of :title, :minimum => 1, :maximum => 60
  validates_length_of :summary, :minimum => 1, :maximum => 60

  scope :enabled_only, -> { where(status: self.statuses[:enable]) }
  scope :pending_only, -> { where(status: self.statuses[:pending]) }
  scope :disable_only, -> { where(status: self.statuses[:disable]) }

  scope :popular, -> { order('comment_count DESC, views DESC') }
  scope :blog_categories_search, -> (category) {
    post_ids = BlogCategory.where('lower(name) LIKE ? ', "%#{category.downcase}%").map(&:blog_posts).flatten(1).map { |p| p.id }
    BlogPost.where('id in (?)', post_ids)
  }

  pg_search_scope :blog_search,
                  against: [:title],
                  associated_against: {
                    blog_categories: [:name],
                    tags: [:name],
                    author: [:first_name, :last_name]
                  },
                  using: {
                    tsearch: {
                      any_word: true,
                      prefix: true
                    }
                  }

  before_save :before_save

  scope :enabled_recent_blog_posts, -> (limit) { where(blog_id: 1, status: 1).order(created_at: :desc).limit(limit) }

  # multisearchable :against => [:name, :content], :if => :deleted_blog_post?, :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  def before_save
    if self.id.nil?
      self.slug = checK_slug_exist(title.parameterize, title.parameterize, 1)
    end
  end

  # with help of Srimal
  def checK_slug_exist(title, slug, counter)
    post = BlogPost.find_by slug: slug
    if !post.nil?
      counter += 1
      slug = "#{title}-#{counter}"
      slug = checK_slug_exist(title, slug, counter)
    end
    slug
  end

  # after_save :notify_author
  def notify_author
    return if status == "pending" || status_was != "pending"
    _message = "Your Blog Post,'#{title}' has been "
    notification = case status
    when "enable"
      Notification.create(
        message: _message << "approved.",
        status: 1,
        notification_type: :blog_post
      )
    when "disable"
      Notification.create(
        message: _message << "rejected.",
        status: 1,
        notification_type: :blog_post
      )
    else
      nil
    end
    unless notification.nil?
      notification.recipients << author
      notification.notifiable = self
      notification.save!
    end
  end
end
