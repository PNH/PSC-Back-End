class Blog < ActiveRecord::Base
  has_many :blog_posts, :dependent => :destroy
  has_many :blog_moderators, :dependent => :destroy

end
