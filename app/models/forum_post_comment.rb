class ForumPostComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :forum_post
  has_many :forum_post_comment_attachments, :dependent => :destroy

  attr_accessor :isowner
end
