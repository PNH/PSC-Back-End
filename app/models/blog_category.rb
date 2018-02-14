class BlogCategory < ActiveRecord::Base
  has_many :blog_post_blog_categories, dependent: :destroy
  has_many :blog_posts, through: :blog_post_blog_categories

  validates :name, presence: true

  before_save :strip_name_validation
  def strip_name_validation
    return if name.nil?
    name.strip!
    unless BlogCategory.find_by(name: name).nil?
      errors.add(:name, "has already been taken")
      false
    else
      self.name = name
    end
  end
end
