class GroupPost < ActiveRecord::Base
  has_many :group_post_comment, :dependent => :destroy
  has_many :group_post_attachment, :dependent => :destroy
  belongs_to :user
  belongs_to :group
  has_many :group_post_like, :dependent => :destroy
  belongs_to :groupposting, polymorphic: true

  # runtime attrs
  attr_accessor :likes
  attr_accessor :liked
  attr_accessor :isowner
  attr_accessor :commentcount

  validates :user_id, presence: true
  validates :group_id, presence: true
  # validates :content, presence: true
end
