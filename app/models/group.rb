class Group < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title], :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  # has_many :moderators, inverse_of: :group, class_name: 'GroupModerator', :dependent => :delete_all
  belongs_to :image, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'
  has_many :users, through: :group_moderators
  has_many :users, through: :group_members
  has_many :group_posts, :dependent => :destroy
  has_many :group_moderators, :dependent => :destroy
  has_many :group_members, :dependent => :destroy
  has_many :group_post_likes, :dependent => :destroy

  scope :recent_groups, -> (limit) { where(status: true).order(created_at: :desc).first(limit) }

# tmp vars
  attr_accessor :ismember
  attr_accessor :ismoderator
  attr_accessor :membercount

  validates :title, presence: true
  validates :description, presence: true
  validates_length_of :description, :minimum => 5, :maximum => 100, :allow_blank => false
  validates_uniqueness_of :title
end
