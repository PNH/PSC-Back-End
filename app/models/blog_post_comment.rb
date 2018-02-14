class BlogPostComment < ActiveRecord::Base
  belongs_to :blog_post, counter_cache: :comment_count
  belongs_to :user

  has_many :blog_post_comments, foreign_key: 'parent_id'

  scope :parent_comments, -> { where(parent_id: nil) }

  # before_save :before_save
  # before_destroy :before_destroy

  # def before_save
  #   if self.id.nil?
  #     byebug()
  #     self.blog_post.comment_count += 1
  #     self.blog_post.save
  #   end
  # end
  #
  # def before_destroy
  #   if self.id.nil?
  #     self.blog_post.comment_count -= 1
  #     self.blog_post.save
  #   end
  # end

end
