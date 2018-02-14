class GroupPostComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :group_post
  has_many :group_post_comment_attachments, :dependent => :destroy

  attr_accessor :isowner
end
